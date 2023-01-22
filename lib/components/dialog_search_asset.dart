import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/asset.dart';
import 'package:telkom/network/api.dart';
import 'package:unicons/unicons.dart';

class SearchAssetScreen extends StatefulWidget {
  const SearchAssetScreen({super.key});

  @override
  State<StatefulWidget> createState() => SearchAssetState();
}

class SearchAssetState extends State<SearchAssetScreen> {
  late List listAssets = <Asset>[];
  List asset = <Asset>[];

  var query = TextEditingController();
  bool isSearch = false;

  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      getAssets();
    });

  }

  void getAssets() async{
    var url = 'assets';
    var res = await Network().getData(url);
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        listAssets.clear();
        resultData['data'].forEach((v) {
          listAssets.add(Asset.fromJson(v));
        });
        asset = listAssets;
      });
    }
  }

  void searchAsset(value) async{
    final searched = await searchString(value);
    print(value);
    setState(() {
      asset = searched;
    });
  }

  searchString(String string) {
    string = string.toLowerCase();

    final matching = asset.where((asset) { return asset.code.toLowerCase() == string || asset.name.toLowerCase() == string || asset.product!.name.toLowerCase() == string  || asset.location!.name.toLowerCase() == string || asset.brand.toLowerCase() == string; }).toList();
    if (matching.length > 0)  return matching;

    return asset.where((asset) { return asset.code.toLowerCase().contains(string) || asset.name.toLowerCase().contains(string) || asset.product!.name.toLowerCase().contains(string) || asset.location!.name.toLowerCase().contains(string) || asset.brand.toLowerCase().contains(string); }).toList();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Search",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 40,
              child: TextField(
                autofocus: true,
                controller: query,
                onChanged: (value){
                  if(value.isNotEmpty && value.length >= 3){
                    searchAsset(value);
                    setState(() {
                      isSearch = true;
                    });
                  }else{
                    asset = listAssets;
                    setState(() {
                      isSearch = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                   focusedBorder: OutlineInputBorder(
                     borderRadius:
                     BorderRadius.all(Radius.circular(30),
                     ),
                     borderSide: BorderSide(color: Colors.black, width: 2),
                   ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(30),
                    ),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  hintText: "Search Data",
                  prefixIcon: Icon(Icons.search, color: Colors.black,),

                  suffixIcon: query.text != '' ? IconButton(
                      icon: Icon(UniconsLine.times_circle, color: Colors.black,),
                      onPressed: () {
                      query.text = '';
                      asset = listAssets;
                      setState(() {
                        isSearch = false;
                      });
                      }) : null,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(30),
                    ),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ),
          ),
          if(isSearch == true)
          Expanded(child: ListView.builder(
              shrinkWrap: true,
              itemCount:  asset.length,
              itemBuilder: (context, index) {
                var item = asset[index];
                if(index < asset.length){
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
          ))
        ],
      ),
    );
  }
}