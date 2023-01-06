import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/asset.dart';
import 'package:telkom/model/asset_type.dart';
import 'package:telkom/model/location.dart';
import 'package:telkom/model/product.dart';
import 'package:telkom/model/product_include.dart';
import 'package:telkom/model/product_price.dart';
import 'package:telkom/network/api.dart';

class SalesOrderDetailDialogScreen extends StatefulWidget {
  final int location_id;
  final dynamic initialData;

  SalesOrderDetailDialogScreen.add(this.location_id,this.initialData);

  SalesOrderDetailDialogScreen.edit(this.location_id,this.initialData);

  @override
  SalesOrderDetailDialogState createState() {
    if (initialData != null) {
      return new SalesOrderDetailDialogState(
          this.location_id,this.initialData
      );
    } else {
      return new SalesOrderDetailDialogState(this.location_id,null);
    }
  }
}

class SalesOrderDetailDialogState extends State<SalesOrderDetailDialogScreen> {

  var quantityContorller = TextEditingController();
  var discountContorller = TextEditingController();

  bool isLoading = false;
  bool listSelectedProduct = false;
  bool submitSelectedProduct = false;
  bool listSelectedTypeAsset = false;
  bool submitSelectedTypeAsset = false;
  bool listSelectedAsset = false;
  bool submitSelectedAsset = false;
  bool listSelectedProductPrices = false;
  bool submitSelectedProductPrices = false;
  bool has_asset_type = false;
  bool has_asset = false;
  bool has_product_prices = false;

  var valueEdit;

  var price;
  var serviceCharge;
  var tax;
  var total;

  var user = {};
  var location_id;

  final form = GlobalKey<FormState>();

  late List listProduct = <Product>[];
  List product = <Product>[];


  late List listProductPrices = <ProductPrices>[];
  List productPrices = <ProductPrices>[];

  late List listProductIncludes = <ProductIncludes>[];
  List productIncludes = <ProductIncludes>[];

  late List listAssetType = <AssetType>[];
  List assetType = <AssetType>[];

  late List listAsset = <Asset>[];
  List asset = <Asset>[];

  late List listLocation = <Location>[];
  List location = <Location>[];

  var selectedProduct = {};
  var selectedTypeAsset = {};
  var selectedAsset = {};
  var selectedProductPrices = {};




  SalesOrderDetailDialogState(this.location_id,this.valueEdit);

  @override
  void initState() {
    super.initState();
    price = 0;
    discountContorller.text = '0';
    quantityContorller.text = '1';
    serviceCharge = 0;
    tax = 0;
    total =0;
    setState(() {
      isLoading = true;
    });
    loadUserData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userSession = jsonDecode(localStorage.getString('user').toString());
    setState(() {
      user = userSession;
    });


    setDataUpdate(valueEdit);
    getProduct();
    product = listProduct;
    // getAssetType();
    // assetType = listAssetType;
    getLocation();
    location = listLocation;
  }

  void setDataUpdate(valueEdit) async {
    print(valueEdit);
    if(valueEdit != null){
        setState(() {
          selectedProduct = valueEdit['selectedProduct'];
          selectedProductPrices = valueEdit['selectedProductPrices'];
          selectedAsset = valueEdit['selectedAsset'];
          quantityContorller.text = valueEdit['quantity'];
          discountContorller.text = valueEdit['discount'];
        });
        getProductById(valueEdit['product_id']);
    }
  }

  void getLocation() async {
    var res = await Network().getData('locations');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        listLocation.clear();
        resultData['data'].forEach((v) {
          listLocation.add(Location.fromJson(v));
        });
      });
    }
  }

  void getProduct() async {

    var res = await Network().getData('products?tenant_id=${user['tenant_id']}');
    var resultData = jsonDecode(res.body);
    // print(tenant_id);
    if (res.statusCode == 200 || res.statusCode == 201) {


      setState(() {
        listProduct.clear();
        resultData['data'].forEach((v) {
          listProduct.add(Product.fromJson(v));
        });
      });
    }
  }

  void getAssetType() async {

    var res = await Network().getData('asset_types');
    var resultData = jsonDecode(res.body);
    // print(tenant_id);
    if (res.statusCode == 200 || res.statusCode == 201) {


      setState(() {
        listAssetType.clear();
        resultData['data'].forEach((v) {
          listAssetType.add(AssetType.fromJson(v));
        });
      });
    }
  }

  void sheetProduct() async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listProduct;
                            setState(() {
                              product = suggestions;
                            });
                          } else {
                            final suggestions = listProduct.where((item) {
                              final name = item.name.toLowerCase();
                              final input = value.toLowerCase();

                              return name.contains(input);
                            }).toList();
                            setState(() {
                              product = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Product',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)
                        ),
                        if (listSelectedProduct == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedProduct = {};
                                listSelectedProduct = false;
                                submitSelectedProduct = true;
                              });
                              refreshSelected();
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: product.length,
                        itemBuilder: (context, index){
                          var item = product[index];
                          return CheckboxListTile(
                            title: Text(product[index].name),
                            value: selectedProduct['id'] == item.id ? true : false,
                            onChanged: (value){
                              setState(() {
                                if (value == true) {
                                  selectedProduct = {'id': item.id, 'name': item.name};

                                  listSelectedProduct = true;
                                  submitSelectedProduct = true;
                                } else {
                                  selectedProduct = {};

                                  listSelectedProduct = false;
                                  submitSelectedProduct = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if(submitSelectedProduct != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFF000075),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              submitSelectedProduct = false;
                              product = listProduct;
                              price = 0;
                              discountContorller.text = '0';
                              quantityContorller.text = '1';
                              serviceCharge = 0;
                              tax = 0;
                              total =0;
                            });
                            refreshSelected();
                            if(selectedProduct.length > 0){
                              getProductById(selectedProduct['id']);
                            }
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ) ,
              ),
            );
          });
        }).whenComplete(()  {
        final suggestions = listProduct;
        setState(() {
          product = suggestions;
        });
    });
  }

  void sheetTypeAsset() async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listAssetType;
                            setState(() {
                              assetType = suggestions;
                            });
                          } else {
                            final suggestions = listAssetType.where((item) {
                              final name = item.name.toLowerCase();
                              final input = value.toLowerCase();

                              return name.contains(input);
                            }).toList();
                            setState(() {
                              assetType = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tipe Asset',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)
                        ),
                        if (listSelectedTypeAsset == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTypeAsset = {};
                                listSelectedTypeAsset = false;
                                submitSelectedTypeAsset = true;
                              });
                              refreshSelected();
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: assetType.length,
                        itemBuilder: (context, index){
                          var item = assetType[index];
                          return CheckboxListTile(
                            title: Text(assetType[index].name),
                            value: selectedTypeAsset['id'] == item.id ? true : false,
                            onChanged: (value){
                              setState(() {
                                if (value == true) {
                                  selectedTypeAsset = {'id': item.id, 'name': item.name};

                                  listSelectedTypeAsset = true;
                                  submitSelectedTypeAsset = true;
                                } else {
                                  selectedTypeAsset = {};

                                  listSelectedTypeAsset = false;
                                  submitSelectedTypeAsset = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if(submitSelectedTypeAsset != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFF000075),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              submitSelectedTypeAsset = false;
                              assetType = listAssetType;
                              selectedAsset ={};
                            });
                            refreshSelected();
                            if(selectedTypeAsset.length > 0 )
                              {
                                getAsset(null,location_id,selectedTypeAsset['id']);
                              }
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ) ,
              ),
            );
          });
        }).whenComplete(() {
          final suggestions = listAssetType;
          setState(() {
            assetType = suggestions;
          });
        });
  }

  void sheetAsset() async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listAsset;
                            setState(() {
                              asset = suggestions;
                            });
                          } else {
                            final suggestions = listAsset.where((item) {
                              final name = item.name.toLowerCase();
                              final input = value.toLowerCase();

                              return name.contains(input);
                            }).toList();
                            setState(() {
                              asset = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Asset',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)
                        ),
                        if (listSelectedAsset == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAsset = {};
                                listSelectedAsset = false;
                                submitSelectedAsset = true;
                              });
                              refreshSelected();
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: asset.length,
                        itemBuilder: (context, index){
                          var item = asset[index];
                          return CheckboxListTile(
                            title: Text(asset[index].name),
                            value: selectedAsset['id'] == item.id ? true : false,
                            onChanged: (value){
                              setState(() {
                                if (value == true) {
                                  selectedAsset = {'id': item.id, 'name': item.name};

                                  listSelectedAsset = true;
                                  submitSelectedAsset = true;
                                } else {
                                  selectedAsset = {};

                                  listSelectedAsset = false;
                                  submitSelectedAsset = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if(submitSelectedAsset != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFF000075),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              submitSelectedAsset = false;
                              asset = listAsset;
                            });
                            refreshSelected();
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ) ,
              ),
            );
          });
        }).whenComplete(() {
      final suggestions = listAsset;
      setState(() {
        asset = suggestions;
      });
    });
  }

  void sheetProductPrices() async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listProductPrices;
                            setState(() {
                              productPrices = suggestions;
                            });
                          } else {
                            final suggestions = listProductPrices.where((item) {
                              final name = item.name.toLowerCase();
                              final input = value.toLowerCase();

                              return name.contains(input);
                            }).toList();
                            setState(() {
                              productPrices = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Product',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)
                        ),
                        if (listSelectedProductPrices == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedProductPrices = {};
                                listSelectedProductPrices = false;
                                submitSelectedProductPrices = true;
                              });
                              refreshSelected();
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: productPrices.length,
                        itemBuilder: (context, index){
                          var item = productPrices[index];
                          return CheckboxListTile(
                            title: Text(productPrices[index].name),
                            value: selectedProductPrices['id'] == item.id ? true : false,
                            onChanged: (value){
                              setState(() {
                                if (value == true) {
                                  selectedProductPrices = {'id': item.id, 'name': item.name};

                                  listSelectedProductPrices = true;
                                  submitSelectedProductPrices = true;
                                } else {
                                  selectedProductPrices = {};

                                  listSelectedProductPrices = false;
                                  submitSelectedProductPrices = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if(submitSelectedProductPrices != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFF000075),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              submitSelectedProductPrices = false;
                              productPrices = listProductPrices;
                            });
                            refreshSelected();
                            if(selectedProductPrices.length >0){
                              getProductPrices(selectedProductPrices['id']);
                            }

                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ) ,
              ),
            );
          });
        }).whenComplete(()  {
      final suggestions = listProductPrices;
      setState(() {
        productPrices = suggestions;
      });
    });
  }

  void refreshSelected() async {
    setState(() {});
  }

  void getProductById(Id) async{
    var res = await Network().getData('products/$Id');
    var resultData = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          listProductPrices.clear();
        });

        if(resultData['data']['has_asset_type'] == 1){
          setState(() {
            // has_asset_type = true;
            has_asset = true;
          });
        }else if(resultData['data']['has_asset_type'] == 0){
            setState(() {
              // has_asset_type = false;
              has_asset = false;
              has_product_prices = false;
              selectedTypeAsset = {};
              selectedAsset = {};
              selectedProductPrices = {};
            });
        }

        if (resultData['data']['has_stock'] == 1 && resultData['data']['has_asset_as_a_stock'] == 1) {
          getAsset(null,location_id,resultData['data']['id']);
          has_asset = true;
        } else {
          has_asset = false;
        }

        if(resultData['data']['has_product_prices'] == 1){

          var product_prices;
          for (var i = 0; i <  resultData['data']['product_prices'].length; i++) {

            if (resultData['data']['has_room'] == 1) {
              for (var j = 0; j < location.length; j++) {
                if (listLocation[j].id == resultData['data']['product_prices'][i]['room_id']) {

                  product_prices = {
                    'id': resultData['data']['product_prices'][i]['id'],
                    'tenant_id': resultData['data']['product_prices'][i]['tenant_id'],
                    'product_id' : resultData['data']['product_prices'][i]['product_id'],
                    'name' : resultData['data']['product_prices'][i]['item'] +' - '+resultData['data']['product_prices'][i]['name']+' : '+resultData['data']['product_prices'][i]['currency_code']+' '+currencyFormat(resultData['data']['product_prices'][i]['price']),
                    'asset_type_id' : resultData['data']['product_prices'][i]['asset_type_id'],
                    'room_id' : resultData['data']['product_prices'][i]['room_id'],
                    'has_quantity' : resultData['data']['product_prices'][i]['has_quantity'],
                    'term': resultData['data']['product_prices'][i]['term'],
                    'item' : resultData['data']['product_prices'][i]['item'],
                    'price' : resultData['data']['product_prices'][i]['price'],
                    'default_quantity' : resultData['data']['product_prices'][i]['default_quantity'],
                  };
                  setState(() {
                    has_product_prices = true;
                    listProductPrices.add(ProductPrices.fromJson(product_prices));
                  });
                  break;

                }
              }
            } else if (resultData['data']['has_asset_type'] == 1) {
               product_prices = {
                'id': resultData['data']['product_prices'][i]['id'],
                'tenant_id': resultData['data']['product_prices'][i]['tenant_id'],
                'product_id' : resultData['data']['product_prices'][i]['product_id'],
                'name' : resultData['data']['product_prices'][i]['item'] +' - '+resultData['data']['product_prices'][i]['name'],
                'asset_type_id' : resultData['data']['product_prices'][i]['asset_type_id'],
                'room_id' : resultData['data']['product_prices'][i]['room_id'],
                'has_quantity' : resultData['data']['product_prices'][i]['has_quantity'],
                'term': resultData['data']['product_prices'][i]['term'],
                'item' : resultData['data']['product_prices'][i]['item'],
                'price' : resultData['data']['product_prices'][i]['price'],
                'default_quantity' : resultData['data']['product_prices'][i]['default_quantity'],
              };
               setState(() {
                 has_product_prices = true;
                 // has_asset_type = false;
                 has_asset = true;
                 listProductPrices.add(ProductPrices.fromJson(product_prices));
               });
            } else {
              // do nothing
            }

          }

          productPrices = listProductPrices;
        }else if(resultData['data']['has_product_prices'] == 0){

          setState(() {
            price = resultData['data']['price'];
            serviceCharge = (price * user['tenant']['service_charge_percentage'] / 100);
            
            var total_tax = (price + serviceCharge) * user['tenant']['tax_percentage'] / 100;
            tax = total_tax.round();

            var total_price = price + serviceCharge + tax;
            total = total_price.round();
            has_product_prices = false;

          });

        }

    }

  }

  void getProductPrices(Id) async{

    for (var i = 0; i < productPrices.length; i++) {
      if (productPrices[i].id == Id) {
        setState(() {
          price = productPrices[i].price;
          serviceCharge = (price * user['tenant']['service_charge_percentage'] / 100);

          var total_tax = (price + serviceCharge) * user['tenant']['tax_percentage'] / 100;
          tax = total_tax.round();

          var total_price = price + serviceCharge + tax;
          total = total_price.round();
        });
        getAsset(null,location_id,productPrices[i].productId);
      }
    }
  }

  void getAsset(Id,locationId,productId) async{
    var url = "assets";

    url += '?get_all=Y';

    if (productId != null) {
      url += '&product_id=' + productId.toString();
    }

    if (locationId != null) {
      url += '&location_id=' + locationId.toString();
    }
    var res = await Network().getData(url);
    var resultData = jsonDecode(res.body);
    print(resultData);
    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        listAsset.clear();
        resultData['data'].forEach((v) {
          listAsset.add(Asset.fromJson(v));
        });
        asset = listAsset;
      });
    }
  }

  void calculatePrice() async{
    var quantity = quantityContorller.text;
    var discount = discountContorller.text;



    if (user['tenant']['tax_percentage'] > 0 && tax > 0) {
      var total_tax = ((price - int.parse(discount) + serviceCharge) * user['tenant']['tax_percentage'] / 100).round();

      setState(() {
        tax = total_tax.round();
      });
    }



    var total_price = ( price - int.parse(discount) + serviceCharge + tax ) * int.parse(quantity);
     setState(() {
       total = total_price.round();
     });

  }

  void submitProduct() async{

    var data = {
      'sales_order_id': '',
      'product_id': selectedProduct['id'],
      'selectedProduct':selectedProduct,
      'selectedProductPrices':selectedProductPrices,
      'selectedAsset':selectedAsset,
      'customer_complimentary_id': null,
      'complimentary_id': null,
      'asset_type_id': null,
      'asset_id': selectedAsset['id'],
      'room_id': null,
      'name': selectedProduct['name'],
      'type': 'charged',
      'has_complimentary':0,
      'has_term': 0,
      'is_repeated_in_term': 0,
      'has_quantity' : 1,
      'term': 'no term',
      'repeated_term': 'no term',
      'started_at': formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()),
      'ended_at': formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()),
      'length_of_term': 1,
      'quantity': quantityContorller.text,
      'total_use_of_complimentary':0,
      'cost': 0,
      'price': price,
      'discount': discountContorller.text,
      'service_charge': serviceCharge,
      'tax': tax,
    };

    Navigator
        .of(context)
        .pop(data);

  }

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Form Tambah Produk",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    child:  Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Produk',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            sheetProduct();
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xFFE1120F),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: size.height / 4,
                                  padding: new EdgeInsets.all(10),
                                  child: Text(
                                    selectedProduct.length > 0
                                        ? selectedProduct['name']
                                        : 'Pilih Product',
                                    overflow: TextOverflow.ellipsis,
                                    style: new TextStyle(
                                      fontSize: 13.0,
                                      fontFamily: 'Roboto',
                                      color: new Color(0xFF212121),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down_circle,
                                    color: Color(0xFFE1120F))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  (
                      has_product_prices
                          ?
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                        child:  Column(
                          children: [
                            Align(
                              child:  Text('Harga Produk',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              alignment: Alignment.centerLeft,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                sheetProductPrices();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Color(0xFFE1120F),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: size.height / 3,
                                      padding: new EdgeInsets.all(10),
                                      child: Text(
                                        selectedProductPrices.length > 0
                                            ? selectedProductPrices['name']
                                            : 'Pilih Harga Produk',
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                          fontSize: 12.0,
                                          fontFamily: 'Roboto',
                                          color: new Color(0xFF212121),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_circle,
                                        color: Color(0xFFE1120F))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                          :
                      new Container()
                  ),
                  (
                      has_asset
                          ?
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                        child:  Column(
                          children: [
                            Align(
                              child:  Text('Asset',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              alignment: Alignment.centerLeft,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                sheetAsset();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Color(0xFFE1120F),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: size.height / 4,
                                      padding: new EdgeInsets.all(10),
                                      child: Text(
                                        selectedAsset.length > 0
                                            ? selectedAsset['name']
                                            : 'Pilih Asset',
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                          fontSize: 13.0,
                                          fontFamily: 'Roboto',
                                          color: new Color(0xFF212121),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_circle,
                                        color: Color(0xFFE1120F))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                          :
                      new Container()
                  ),

                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    child:  Column(
                      children: [
                        Align(
                          child:  Text('Jumlah',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          alignment: Alignment.centerLeft,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: quantityContorller,
                          keyboardType: TextInputType.number,

                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelText: "",
                          ),
                          onChanged: (value){
                            if(value.isNotEmpty && value != 0){
                              calculatePrice();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    child:  Column(
                      children: [
                        Align(
                          child:  Text('Diskon',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          alignment: Alignment.centerLeft,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: discountContorller,
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            if(value.isNotEmpty){
                              calculatePrice();
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelText: "",
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              height: 250,
              color: Colors.white,
              padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              child: Column(
                children: [
                  Align(
                    child:  Text('Rincian Harga',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 5),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          child:  Text('Detail Harga',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black)),
                          alignment: Alignment.centerLeft,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currencyFormat(price), style: TextStyle(
                              fontSize: 16,
                          ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(color:Colors.grey),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 5),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          child:  Text('Pajak',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black)),
                          alignment: Alignment.centerLeft,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currencyFormat(tax), style: TextStyle(
                              fontSize: 16,
                          ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(color:Colors.grey),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          child:  Text('Total Harga',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          alignment: Alignment.centerLeft,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currencyFormat(total), style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
          color: Colors.white,
        height: 100,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              height: 50,
              width: size.width,
              decoration: BoxDecoration(
                  color: Color(0xFFE50404),
                  borderRadius: BorderRadius.circular(18)),
              child: TextButton(
                onPressed: () {
                  submitProduct();
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}