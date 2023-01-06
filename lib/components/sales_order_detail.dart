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
import 'package:telkom/model/sales_order.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final dynamic initialData;

  SalesOrderDetailScreen.add(this.initialData);

  @override
  SalesOrderDetailState createState() {
    if (initialData != null) {
      return new SalesOrderDetailState(
          initialData
      );
    } else {
      return new SalesOrderDetailState(null);
    }
  }
}

class SalesOrderDetailState extends State<SalesOrderDetailScreen> {
  bool isLoading = false;
  late SalesOrder salesOrder;

  var sales_order_id;

  SalesOrderDetailState(this.sales_order_id);


  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }


  void getData() async{
    print(sales_order_id);
    var res = await Network().getData('sales_orders/$sales_order_id');
    var body = json.decode(res.body);

    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      print(resultData['data']);
      setState(() {
        salesOrder = SalesOrder.fromJson(resultData['data']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Sales Order Detail",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
              },
              icon: Icon(Icons.notifications, color: Colors.black),
            ),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xffD9D9D9),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/hero_profile.png",
                  height: 40.0,
                  width: 40.0,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: isLoading
    ? Center(child: CircularProgressIndicator())
        : Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Column(
              children: [
                Row(
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
                            salesOrder.code.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 210,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Nama',
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
                            salesOrder.name.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Klien',
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
                            salesOrder.customer!.name.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Lokasi',
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
                            salesOrder.location!.name.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),

              ],
            ),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Detail Pesanan Barang', style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  SizedBox(height: 20,),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: salesOrder.salesOrderDetail.length,
                      itemBuilder: (context, index) {
                        var item = salesOrder.salesOrderDetail[index];
                        return Container(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Divider(color: Colors.grey,)
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

}