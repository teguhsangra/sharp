import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/components/sales_order_detail.dart';
import 'package:telkom/model/sales_order.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/request_order/detail_request_order.dart';
import 'package:telkom/ui/sales_order/form_sales_order.dart';

class SalesOrderScreen extends StatefulWidget {
  const SalesOrderScreen({super.key});

  @override
  State<StatefulWidget> createState() => SalesOrderState();
}

class SalesOrderState extends State<SalesOrderScreen> {
  bool isLoading = true;
  var user = {};
  var access_group ={};
  List<SalesOrder> salesOrder = [];
  String? selectedFilter = 'draft';

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
    getRequestOrder();
  }
  void getAccessGroup() async{
    var access_group_id = user['person']['employee']['access_group_id'];
    var res = await Network().getData('get_access_group??link=sales_orders&access_group_id=$access_group_id');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      access_group = resultData['data'];
    }
  }

  void getRequestOrder() async {
    var res = await Network().getData('sales_orders?this_year=Y&select_by=status&select_query=${selectedFilter}');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        salesOrder.clear();
        resultData['data'].forEach((detailData) {
          salesOrder.add(SalesOrder.fromJson(detailData));
        });
      });
    }
    getAccessGroup();
  }

  void filterRequestOrder() async{
    var url = 'sales_orders?this_year=Y&select_by=status&select_query=${selectedFilter}';
    if(selectedFilter == 'semua'){
      url = 'request_orders?this_year=Y';
    }
    var res = await Network().getData(url);
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        salesOrder.clear();
        resultData['data'].forEach((detailData) {
          salesOrder.add(SalesOrder.fromJson(detailData));
        });
      });
    }
  }

  void sheetMenuCard(Id,status) async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder:
              (context,
              StateSetter setState) {
            return Container(
              width: size.width,
              height: size.height * 0.2,
              child: Padding(
                padding:
                EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration:
                        BoxDecoration(
                          borderRadius: BorderRadius
                              .all(Radius
                              .circular(
                              10.0)),
                          color:
                          Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 30.0),
                    GestureDetector(
                      onTap: () async {
                          Navigator.pop(context);
                          updateSalesOrder(Id,status);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.update),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Approve Sales order',
                            style: TextStyle(
                                fontSize:
                                16),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                  ],
                ),
              ),
            );
          });
        });
  }

  void updateSalesOrder(Id, status) async{
    var data = {
      "status": status
    };

    var res = await Network().putUrl('sales_orders/$Id/update_status?show_type=test', data);
    var body = json.decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      setState(() {
        status = "draft";
      });
      getRequestOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Sales Order",
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
              icon: Icon(Icons.notifications, color: Color(0xFFE50404)),
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
        elevation: 0,
      ),
      body:
      isLoading ?
      Container(
        margin:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ) :
      RefreshIndicator(
        onRefresh: () async {
          getRequestOrder();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: size.height / 10,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ChoiceChip(
                        padding: EdgeInsets.all(10),
                        backgroundColor: Colors.grey,
                        selectedColor: Color(0xFFE50404),
                        selected: selectedFilter == 'draft'
                            ? true
                            : false,
                        label: Text("Request",style: TextStyle(color: Colors.white)),

                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedFilter = 'draft';
                              filterRequestOrder();
                            });
                          }

                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ChoiceChip(
                        padding: EdgeInsets.all(10),
                        backgroundColor: Colors.grey,
                        selectedColor: Color(0xFFE50404),
                        selected: selectedFilter == 'posted'
                            ? true
                            : false,
                        label: Text("Approve",style: TextStyle(color: Colors.white)),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              selectedFilter = 'posted';
                              filterRequestOrder();
                            } else {
                              selectedFilter = '';
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ChoiceChip(
                        padding: EdgeInsets.all(10),
                        backgroundColor: Colors.grey,
                        selectedColor: Color(0xFFE50404),
                        selected: selectedFilter == 'cancel'
                            ? true
                            : false,
                        label: Text("Reject",style: TextStyle(color: Colors.white)),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              selectedFilter = 'cancel';
                              filterRequestOrder();
                            } else {
                              selectedFilter = '';
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: salesOrder.length,
                  itemBuilder: (context, index) {
                    var item = salesOrder[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) {
                              return SalesOrderDetailScreen.add(item.id);
                            }),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(15),
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
                                      Icons.calendar_today_outlined,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text('Request Order',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                      )
                                  )
                                ],
                              ),
                              if(access_group['is_update'] == 1 && item.status == 'draft')
                              GestureDetector(
                                onTap:(){
                                  sheetMenuCard(item.id, 'posted');
                                },
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.black,

                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 2,),
                          Divider(color: Colors.grey),
                          SizedBox(height: 10,),
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
                                      'Tanggal Order',
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
                                      formatDate('yyyy-MM-dd HH:mm', item.createdAt),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 25,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
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
                                      item.customer!.name.toString(),
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
                                      item.location!.name.toString(),
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
                          SizedBox(height: 15,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Produk',
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
                              item.product!.name.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total Harga',
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
                              currencyFormat(int.parse(item.totalPrice.toString())),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            width: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        30.0),
                                  ),
                                  elevation: 0,
                                  color:
                                  item.status == 'reject'?
                                  Color(0xFFFFEBEB)
                                      : item.status == 'posted' ? Color(0xFF50C594)
                                      : Color(0XFFFFF5E8)
                                  ,
                                  child: SizedBox(
                                      width: size.width / 4,
                                      height: 35,
                                      child: Center(child:
                                      Text(item.status == 'draft' ? 'Request' : item.status == 'posted' ? 'Approve' : 'Reject',
                                        style: TextStyle(
                                            color: item.status == 'reject'?
                                            Color(0xFFCB4C4D)
                                                : item.status == 'posted' ? Colors.white
                                                : Color(0XFFEA9B3F),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14
                                        ),
                                      ))
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]),
                      ),
                    );
                  }
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var dataCustomer =
          await Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) {
                return new FormSalesOrderScreen();
              },
              fullscreenDialog: true));
          if (dataCustomer != null) {
            getRequestOrder();
          }


        },
        backgroundColor: Color(0xFFE50404),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }


}
