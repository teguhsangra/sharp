import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:telkom/components/dialog_alert_success.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/asset.dart';
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

  late List assets = <Asset>[];



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
    var res = await Network().getData('assets?page=$present');
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
    }
  }

  void moreRequestOrder(page) async{
    var res = await Network().getData('assets?page=$page');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        perPage = resultData['data']['per_page'];
        totalPage = resultData['data']['total'];

        assets.clear();
        resultData['data']['data'].forEach((v) {
          assets.add(Asset.fromJson(v));
        });
      });
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
              },
              icon: Icon(UniconsLine.search)
          ),
          IconButton(
              onPressed: (){
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
}

