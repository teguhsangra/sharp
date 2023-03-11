import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:telkom/components/dialog_alert_success.dart';
import 'package:telkom/components/dialog_search_asset.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/asset.dart';
import 'package:telkom/model/location.dart';
import 'package:telkom/model/product.dart';
import 'package:telkom/ui/asset/form_asset.dart';
import 'package:unicons/unicons.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';


class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<StatefulWidget> createState() => AssetState();
}

class AssetState extends State<AssetScreen> {
  final scrollController = ScrollController();
  bool isLoading = true;
  bool isLoadingMore = false;
  var user = {};
  int present = 1;
  int perPage = 0;
  int totalPage =0;
  var selectedLocation ={};
  var selectedProduct={};

  late List<Asset> assets = [];
  late List listProduct = <Product>[];
  List products = <Product>[];

  late List listLocation = <Location>[];
  List locations = <Location>[];

  bool listSelectedLocation = false;
  bool submitSelectedLocation = false;

  bool listSelectedProduct = false;
  bool submitSelectedProduct = false;



  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
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
      present = 1;
    });
    getAssets();
  }

  void getAssets() async{
    var url = 'assets?page=$present';
    if(selectedLocation.length != 0 && selectedProduct.length != 0){
      url =  url+'&location_id=${selectedLocation['id']}'+'&product_id=${selectedProduct['id']}';
    }else if(selectedLocation.length != 0 && selectedProduct.length == 0){
      url =  url+'&location_id=${selectedLocation['id']}';
    }else if(selectedLocation.length == 0 && selectedProduct.length != 0){
      url =  url+'&product_id=${selectedProduct['id']}';

    }

    var res = await Network().getData(url);
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        assets.clear();
        resultData['data']['data'].forEach((v) {
          assets.add(Asset.fromJson(v));
        });
        perPage = resultData['data']['per_page'];
        totalPage = resultData['data']['total'];
      });
      getLocation();
      getProduct();
    }
  }

  void moreRequestOrder(page) async{
    var url = 'assets?page=$page';
    if(selectedLocation.length != 0 && selectedProduct.length != 0){
      url =  url+'&location_id=${selectedLocation['id']}'+'&product_id=${selectedProduct['id']}';
    }else if(selectedLocation.length != 0 && selectedProduct.length == 0){
      url =  url+'&location_id=${selectedLocation['id']}';
    }else if(selectedLocation.length == 0 && selectedProduct.length != 0){
      url =  url+'&product_id=${selectedProduct['id']}';

    }

    var res = await Network().getData(url);
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        perPage = resultData['data']['per_page'];
        totalPage = resultData['data']['total'];
        resultData['data']['data'].forEach((v) {
          assets.add(Asset.fromJson(v));
        });
      });
      getLocation();
      getProduct();
    }
  }

  Future<void> _scrollListener() async{
    if(scrollController.position.pixels == scrollController.position.maxScrollExtent){

      setState(() {
        isLoadingMore = true;
      });
      loadMore();
      setState(() {
        isLoadingMore = false;
      });
    }
  }
  Future<void> loadMore() async{
    setState(() {
      if(present != totalPage) {
        present +=1;
        moreRequestOrder(present);
      }
    });
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

        locations = listLocation;
      });
    }
  }

  void getProduct() async {
    var res = await Network().getData('products?tenant_id=${user['tenant_id']}');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        listProduct.clear();
        resultData['data'].forEach((v) {
          listProduct.add(Product.fromJson(v));
        });

        products = listProduct;
      });
    }
  }




  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Data Barang",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchAssetScreen()),
                );
              },
              icon: Icon(UniconsLine.search)
          ),
          IconButton(
              onPressed: (){
                sheetFilter();
              },
              icon: Icon(UniconsLine.filter)
          ),
        ],
        elevation: 0,
      ),
      body: isLoading ?
          Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ) : RefreshIndicator(
            onRefresh: () async {
              loadUserData();
            },
            child: Column(
              children: [
                Expanded(child: ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount:  assets.length,
                    itemBuilder: (context, index) {
                      var item = assets[index];
                      if(index < assets.length){
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 2,
                                    // Shadow position
                                    spreadRadius: 3,
                                    offset: const Offset(0, 2)),
                              ]),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Color(0xFFE50404), shape: BoxShape.circle),
                                      child: Icon(
                                        UniconsLine.gift,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Text('Barang',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                  ],
                                ),

                              ],
                            ),
                            SizedBox(height: 2,),
                            Divider(color: Colors.grey),
                            SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Kode',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.code.toString(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Location',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.location!.name.toString(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item.name.toString(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Brand',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item.brand.toString(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Harga',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    currencyFormat(item.product!.price),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        );
                      }else{
                        return Center(child: CircularProgressIndicator(),);
                      }
                    }
                )),
                if(isLoadingMore == true)
                  Padding(
                      padding: EdgeInsets.only(top: 10,bottom: 40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                  )
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res =
          await Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) {
                return new FormAssetScreen();
              },
              fullscreenDialog: true));

          if (res == 'success') {

            loadUserData();
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) {
                  return new DialogPopUpSuccess(text: 'Sukses tambah data barang.',);
                },
                fullscreenDialog: true));


          }
        },
        backgroundColor: Color(0xFFE50404),
        child: const Icon(
          UniconsLine.plus,
          color: Colors.white,
        ),
      ),
    );
  }



  void sheetFilter() async{
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
              height: size.height * 0.6,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
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
                    const SizedBox(height: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Filter', style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            child: Column(
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
                                    GestureDetector(
                                      onTap: () {
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
                                            }).whenComplete(()  {
                                          final suggestions = listProduct;
                                          setState(() {
                                            products = suggestions;
                                          });
                                        });
                                      },
                                      child: Text('Lihat semua',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
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
                          SizedBox(height: 20,),
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Lokasi',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
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
                                                                final suggestions = listLocation;
                                                                setState(() {
                                                                  locations = suggestions;
                                                                });
                                                              } else {
                                                                final suggestions = listLocation.where((item) {
                                                                  final name = item.name.toLowerCase();
                                                                  final input = value.toLowerCase();

                                                                  return name.contains(input);
                                                                }).toList();
                                                                setState(() {
                                                                  locations = suggestions;
                                                                });
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(height: 20,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('Location',
                                                                style: TextStyle(
                                                                    fontSize: 17.0,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Colors.black)
                                                            ),
                                                            if (listSelectedLocation == true)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    selectedLocation = {};
                                                                    listSelectedLocation = false;
                                                                    submitSelectedLocation = true;
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
                                                            itemCount: locations.length,
                                                            itemBuilder: (context, index){
                                                              var item = locations[index];
                                                              return CheckboxListTile(
                                                                title: Text(locations[index].name),
                                                                value: selectedLocation['id'] == item.id ? true : false,
                                                                onChanged: (value){
                                                                  setState(() {
                                                                    if (value == true) {
                                                                      selectedLocation = {'id': item.id, 'name': item.name};

                                                                      listSelectedLocation = true;
                                                                      submitSelectedLocation = true;
                                                                    } else {
                                                                      selectedLocation = {};

                                                                      listSelectedLocation = false;
                                                                      submitSelectedLocation = false;
                                                                    }
                                                                  });
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        if(submitSelectedLocation != false)
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
                                                                  submitSelectedLocation = false;
                                                                  locations = listLocation;
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
                                            }).whenComplete(()  {
                                          final suggestions = listLocation;
                                          setState(() {
                                            locations = suggestions;
                                          });
                                        });
                                      },
                                      child: Text('Lihat semua',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
                                if(selectedLocation.length > 0)
                                  Container(
                                    width: size.height / 2,
                                    padding: new EdgeInsets.only(top: 10),
                                    child: Text(
                                      selectedLocation.length > 0
                                          ? selectedLocation['name']
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
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      height: 50,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          color: Color(0xFFD60303),
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          getAssets();
                        },
                        child: const Text(
                          'Tampilkan',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }




  void refreshSelected() async {
    setState(() {});
  }
}

