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
  var user = {};
  var access_group ={};

  var sales_order_id;
  int total_diskon = 0;
  int total_price = 0;
  int total_tax = 0;
  int grand_total = 0;

  SalesOrderDetailState(this.sales_order_id);


  showAlertDialog(BuildContext context) {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    super.initState();
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
    getAccessGroup();
    getData();
  }

  void getAccessGroup() async{
    var access_group_id = user['person']['employee']['access_group_id'];
    var res = await Network().getData('get_access_group??link=sales_orders&access_group_id=$access_group_id');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      access_group = resultData['data'];
    }
  }

  void getData() async{

    var res = await Network().getData('sales_orders/$sales_order_id');
    var body = json.decode(res.body);

    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        salesOrder = SalesOrder.fromJson(resultData['data']);
      });
      countPrice();
    }
  }

  void countPrice() async {
    var price = 0;
    var diskon =0;
    var pajak=0;
    var service = 0;


    for (var items in salesOrder.salesOrderDetail) {
      int item_price = int.parse(items.price.toString()) * int.parse(items.quantity.toString());
      price = price + item_price;

      int item_diskon = int.parse(items.discount.toString());
      diskon = diskon + item_diskon;

      int item_tax = int.parse(items.tax.toString());
      pajak = pajak + item_tax;

      int item_service = int.parse(items.service_charge.toString());
      service = service+item_service;
    }
    setState(() {
      total_diskon = diskon;
      total_price = price;
      total_tax = pajak;
      grand_total =(price - diskon) + service + pajak;
    });
  }

  void approveSaleOrder() async{
    var data = {
      "status": 'posted'
    };
    showAlertDialog(context);
    var res = await Network().putUrl('sales_orders/$sales_order_id/update_status?show_type=test', data);
    var body = json.decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      await Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pop('success');
      });
    }
  }


  void sheetApprove() {
    Size size = MediaQuery
        .of(context)
        .size;
    showModalBottomSheet(
        enableDrag: true,
        isDismissible: true,
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Update Lokasi', style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),)
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Image.asset(
                          "assets/images/no_image_pelaporan.png",
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 20,),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Apa anda yakin untuk approve sales order tersebut?',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              height: 50,
                              width: size.width / 3,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(18)),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              height: 50,
                              width: size.width / 3,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(18)),
                              child: TextButton(
                                onPressed: () {
                                  approveSaleOrder();
                                },
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            )
                          ],
                        )
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: const Text(
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
              icon: const Icon(Icons.notifications, color: Colors.black),
            ),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xffD9D9D9),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/hero_profile.png",
                  height: 40.0,
                  width: 40.0,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Kode',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              salesOrder.code.toString(),
                              style: const TextStyle(
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Nama',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              salesOrder.name.toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Klien',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              salesOrder.customer!.name.toString(),
                              style: const TextStyle(
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Lokasi',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              salesOrder.location!.name.toString(),
                              style: const TextStyle(
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
            const SizedBox(height: 10,),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Catatan', style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  const SizedBox(height: 20,),
                 Align(
                   alignment: Alignment.centerLeft,
                   child:  Text(salesOrder.remarks != null ? salesOrder.remarks.toString() : '',maxLines: 3,softWrap: true,style: const TextStyle(
                       fontSize: 18
                   ),),
                 )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Detail Pesanan Barang', style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  const SizedBox(height: 20,),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: salesOrder.salesOrderDetail.length,
                      itemBuilder: (context, index) {
                        var item = salesOrder.salesOrderDetail[index];
                        var total = int.parse(item.price.toString()) * int.parse(item.quantity.toString())-int.parse(item.discount.toString()) + int.parse(item.service_charge.toString()) + int.parse(item.tax.toString());
                        return Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item.name,
                                        maxLines: 2,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 5,),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item.quantity.toString()+' x '+currencyFormat(int.parse(item.price.toString())),
                                        style: const TextStyle(
                                          fontSize: 14,),
                                      ),
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('Diskon', style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey
                                              ),),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('${currencyFormat(int.parse(item.discount.toString()))}', style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black
                                              ),),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 50,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('Tax', style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey
                                              ),),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('${currencyFormat(int.parse(item.tax.toString()))}', style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black
                                              ),),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Column(
                                      children: [
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Total', style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey
                                          ),),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('${currencyFormat(total)}', style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                width: 250,
                              ),
                              const Divider(color: Colors.grey,)
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
             color: Colors.white,
             padding: const EdgeInsets.only(left: 20,top: 20, right: 20, bottom: 20),
             child: Column(
               children: [
                 const Align(
                   alignment: Alignment.centerLeft,
                   child: Text('Rincian Total Harga', style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.bold
                   ),),
                 ),
                 const SizedBox(height: 20,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Align(
                       alignment: Alignment.centerLeft,
                       child: Text('Total Diskon',
                           style: TextStyle(
                               fontSize: 14.0,
                               fontWeight: FontWeight.w600,
                               color: Colors.black)),
                     ),
                     Text('${currencyFormat(total_diskon)}',
                         style: const TextStyle(
                             fontSize: 14.0,
                             fontWeight: FontWeight.w600,
                             color: Colors.black))
                   ],
                 ),
                 const SizedBox(height: 10,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Align(
                       alignment: Alignment.centerLeft,
                       child: Text('Total Harga',
                           style: TextStyle(
                               fontSize: 14.0,
                               fontWeight: FontWeight.w600,
                               color: Colors.black)),
                     ),
                     Text('${currencyFormat(total_price)}',
                         style: const TextStyle(
                             fontSize: 14.0,
                             fontWeight: FontWeight.w600,
                             color: Colors.black))
                   ],
                 ),
                 const SizedBox(height: 10,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Align(
                       alignment: Alignment.centerLeft,
                       child: Text('Total Pajak',
                           style: TextStyle(
                               fontSize: 14.0,
                               fontWeight: FontWeight.w600,
                               color: Colors.black)),
                     ),
                     Text('${currencyFormat(total_tax)}',
                         style: const TextStyle(
                             fontSize: 14.0,
                             fontWeight: FontWeight.w600,
                             color: Colors.black))
                   ],
                 ),
                 const SizedBox(height: 10,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Align(
                       alignment: Alignment.centerLeft,
                       child: Text('Total Keseluruhan',
                           style: TextStyle(
                               fontSize: 14.0,
                               fontWeight: FontWeight.w600,
                               color: Colors.black)),
                     ),

                     Text('${currencyFormat(grand_total)}',
                         style: const TextStyle(
                             fontSize: 14.0,
                             fontWeight: FontWeight.w600,
                             color: Colors.black))
                   ],
                 ),
               ],
             ),
           )
          ],
      ),
        ),

      bottomNavigationBar: isLoading
          ? const Center(child: CircularProgressIndicator())
          :
          Container(
          height: salesOrder.status != 'posted' && salesOrder.status != 'cancel' && access_group['is_update'] == 1 ? 100 : 0,
          child: Column(
          children: [
            if(salesOrder.status != 'posted' && salesOrder.status != 'cancel' && access_group['is_update'] == 1 )
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              height: 50,
              width: size.width,
              decoration: BoxDecoration(
                  color: const Color(0xFFE50404),
                  borderRadius: BorderRadius.circular(18)),
              child: TextButton(
                onPressed: () {
                  sheetApprove();
                },
                child: const Text(
                  'Approve',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      )



    );
  }

}