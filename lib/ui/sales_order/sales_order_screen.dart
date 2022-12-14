import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:telkom/components/helper.dart';
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
  List<SalesOrder> salesOrder = [];
  String? selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getRequestOrder();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getRequestOrder() async {
    var res = await Network().getData('sales_orders?this_year=Y');
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

  // void filterRequestOrder() async{
  //   var url = 'request_orders?this_year=Y&select_by=status&select_query=${selectedFilter}';
  //   if(selectedFilter == 'semua'){
  //     url = 'request_orders?this_year=Y';
  //   }
  //   var res = await Network().getData(url);
  //   if (res.statusCode == 200) {
  //     var resultData = jsonDecode(res.body);
  //
  //     setState(() {
  //       requestOrders.clear();
  //       resultData['data'].forEach((detailData) {
  //         requestOrders.add(RequestOrder.fromJson(detailData));
  //       });
  //     });
  //   }
  // }

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
                        selected: selectedFilter == 'semua'
                            ? true
                            : false,
                        label: Text("semua",style: TextStyle(color: Colors.white)),

                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedFilter = 'semua';
                              // filterRequestOrder();
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
                        selected: selectedFilter == 'submission'
                            ? true
                            : false,
                        label: Text("submission",style: TextStyle(color: Colors.white)),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              selectedFilter = 'submission';
                              // filterRequestOrder();
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
                        selected: selectedFilter == 'approve'
                            ? true
                            : false,
                        label: Text("approve",style: TextStyle(color: Colors.white)),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              selectedFilter = 'approve';
                              // filterRequestOrder();
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
                        selected: selectedFilter == 'reject'
                            ? true
                            : false,
                        label: Text("reject", style: TextStyle(color: Colors.white),),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              selectedFilter = 'reject';
                              // filterRequestOrder();
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
                              return RequestOrderDetailScreen(requestOrderId: item.id);
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
                              Text(
                                formatDate('yyyy-MM-dd HH:mm', item.createdAt),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2,),
                          Divider(color: Colors.grey),
                          SizedBox(height: 10,),
                          Container(
                              width: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(item.product!.name,
                                    softWrap: true,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12
                                    ),
                                  )
                                ],
                              )
                          ),
                          SizedBox(height: 20,),

                          // Container(
                          //   width: 400,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Card(
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius:
                          //           BorderRadius.circular(
                          //               30.0),
                          //         ),
                          //         elevation: 0,
                          //         color:
                          //         item.status == 'reject'?
                          //         Color(0xFFFFEBEB)
                          //             : item.status == 'approve' ? Color(0xFF50C594)
                          //             : Color(0XFFFFF5E8)
                          //         ,
                          //         child: SizedBox(
                          //             width: size.width / 4,
                          //             height: 35,
                          //             child: Center(child: Text(item.status,
                          //               style: TextStyle(
                          //                   color: item.status == 'reject'?
                          //                   Color(0xFFCB4C4D)
                          //                       : item.status == 'approve' ? Colors.white
                          //                       : Color(0XFFEA9B3F),
                          //                   fontWeight: FontWeight.bold,
                          //                   fontSize: 14
                          //               ),
                          //             ))
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // )
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormSalesOrderScreen(),
            ),
          );
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
