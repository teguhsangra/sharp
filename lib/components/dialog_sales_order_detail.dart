import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/dialog_produk_category.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/asset.dart';
import 'package:telkom/model/product.dart';
import 'package:telkom/network/api.dart';

class SalesOrderDetailDialogScreen extends StatefulWidget {
  final int location_id;
  final dynamic editData;

  SalesOrderDetailDialogScreen.add(this.location_id,this.editData);

  SalesOrderDetailDialogScreen.edit(this.location_id,this.editData);

  @override
  SalesOrderDetailDialogState createState() {
    if (this.location_id != null) {
      return new SalesOrderDetailDialogState(
          this.location_id, this.editData
      );
    } else {
      return new SalesOrderDetailDialogState(this.location_id,this.editData);
    }
  }
}

class SalesOrderDetailDialogState extends State<SalesOrderDetailDialogScreen> {
  final form = GlobalKey<FormState>();
  var quantityContorller = TextEditingController();
  var discountContorller = TextEditingController();

  bool isLoading = false;
  bool isProduct = false;
  bool listSelectedProduct = false;
  bool submitSelectedProduct = false;
  bool listSelectedAsset = false;
  bool submitSelectedAsset = false;
  bool has_asset = false;

  late List listProduct = <Product>[];
  List products = <Product>[];
  late List listAsset = <Asset>[];
  List asset = <Asset>[];
  var editData;



  var user = {};
  var location_id;
  var price;
  var serviceCharge;
  var tax;
  var total;


  var selectedCategory = {};
  var selectedProduct = {};
  var selectedAsset = {};




  SalesOrderDetailDialogState(this.location_id,this.editData);

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
    if(editData != null){
      setDataUpdate();
    }
  }

  void setDataUpdate() async {
    if(editData != null){
      setState(() {
        selectedCategory = editData['selectedCategory'];
        selectedProduct = editData['selectedProduct'];
        selectedAsset = editData['selectedAsset'];
        quantityContorller.text = editData['quantity'];
        discountContorller.text = editData['discount'];
        isProduct = true;
      });
      getProductById(editData['product_id']);
    }
  }

  void getCategorybyId() async {
    var category_id = selectedCategory['id'];
    var res = await Network().getData('product_categories/$category_id');
    var resultData = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        listProduct.clear();
        resultData['data']['products'].forEach((v) {
          listProduct.add(Product.fromJson(v));
        });
        products = listProduct;
        isProduct = true;
      });
    }
  }



  void refreshSelected() async {
    setState(() {});
  }

  void openDialogCateory() async{

    var res =
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new ProductCategoryDialogScreen.add(0,null);
        }));

    if(res != null)
    {
      setState(() {
        selectedProduct ={};
        selectedCategory = res;
      });
      getCategorybyId();
    }
  }

  void sheetProduct() async{
    setState(() {
      selectedAsset ={};
    });
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
                              products = suggestions;
                            });
                          } else {
                            final suggestions = listProduct.where((item) {
                              final name = item.name.toLowerCase();
                              final input = value.toLowerCase();

                              return name.contains(input);
                            }).toList();
                            setState(() {
                              products = suggestions;
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
                        itemCount: products.length,
                        itemBuilder: (context, index){
                          var item = products[index];
                          return CheckboxListTile(
                            title: Text(products[index].name),
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
                              products = listProduct;
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
        products = suggestions;
      });
    });
  }

  void getProductById(Id) async{
    var res = await Network().getData('products/$Id');
    var resultData = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {



      if (resultData['data']['has_stock'] == 1 && resultData['data']['has_asset_as_a_stock'] == 1) {
        // getAsset(location_id,resultData['data']['id']);
        has_asset = true;
        setState(() {
          listAsset.clear();
          for(var data in resultData['data']['assets']){
            if(data['is_sold'] == 0){
              listAsset.add(Asset.fromJson(data));
            }
          }

          asset = listAsset;
        });
      } else {
        has_asset = false;
      }

      setState(() {
        price = resultData['data']['price'];
        serviceCharge = (price * user['tenant']['service_charge_percentage'] / 100);

        var total_tax = (price + serviceCharge) * user['tenant']['tax_percentage'] / 100;
        tax = total_tax.round();

        var total_price = price + serviceCharge + tax;
        total = total_price.round();
      });

    }

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
                            title: Text(item.name+' '+item.brand),
                            value: selectedAsset['id'] == item.id ? true : false,
                            onChanged: (value){
                              setState(() {
                                if (value == true) {
                                  selectedAsset = {'id': item.id, 'name': item.name+' '+item.brand};

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
      'selectedCategory':selectedCategory,
      'selectedProduct':selectedProduct,
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
    if(selectedCategory.length == 0 && selectedProduct.length == 0 || selectedAsset.length == 0){
      alertDialogForm();
    }else{
      Navigator
          .of(context)
          .pop(data);
    }


  }

  void alertDialogForm() {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        enableDrag: false,
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
              height: size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 30,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Image.asset(
                          "assets/images/no_image_pelaporan.png",
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Mohon lengkapi isian form, kategori produk, produk / asset dan jumlah tidak boleh kosong.',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Produk Category',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            if(editData == null)
                            GestureDetector(
                              onTap: () {
                                openDialogCateory();
                              },
                              child: Text('Lihat semua',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if(selectedCategory.length > 0)
                        Container(
                          width: size.height / 2,
                          padding: new EdgeInsets.only(top: 10),
                          child: Text(
                            selectedCategory.length > 0
                                ? selectedCategory['name']
                                : 'Pilih Product Category',
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontSize: 13,
                              fontFamily: 'Roboto',
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  if(isProduct)
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    child:  Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Produk',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            if(editData == null)
                            GestureDetector(
                              onTap: () {
                                sheetProduct();
                              },
                              child: Text('Lihat semua',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if(selectedProduct.length > 0)
                        Container(
                          width: size.height / 2,
                          padding: new EdgeInsets.only(top: 10),
                          child: Text(
                            selectedProduct.length > 0
                                ? selectedProduct['name']
                                : '',
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                              fontSize: 13,
                              fontFamily: 'Roboto',
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                        )
                      ],
                    ),
                  ),
                  (
                      has_asset
                          ?
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                        child:  Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  child:  Text('Asset',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                  alignment: Alignment.centerLeft,
                                ),
                                if(editData == null)
                                GestureDetector(
                                  onTap: () {
                                    sheetAsset();
                                  },
                                  child: Text('Lihat semua',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.height / 2,
                              padding: new EdgeInsets.all(10),
                              child: Text(
                                selectedAsset.length > 0
                                    ? selectedAsset['name']
                                    : '',
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                  fontSize: 13.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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