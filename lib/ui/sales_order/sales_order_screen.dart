import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/dialog_alert_success.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/components/sales_order_detail.dart';
import 'package:telkom/model/sales_order.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/services/sales_order.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/request_order/detail_request_order.dart';
import 'package:telkom/ui/sales_order/form_sales_order.dart';
import 'package:unicons/unicons.dart';

class SalesOrderScreen extends StatefulWidget {
  const SalesOrderScreen({super.key});

  @override
  State<StatefulWidget> createState() => SalesOrderState();
}

class SalesOrderState extends State<SalesOrderScreen> {
  final scrollController = ScrollController();
  bool isLoading = true;
  bool isLoadingMore = false;
  var _salesOrder = SalesOrderService();
  var user = {};
  var access_group ={};
  List<SalesOrder> salesOrder = [];
  String? selectedFilter = 'draft';
  int counter = 0;
  int count_pending = 0;

  int present = 1;
  int perPage = 0;
  int totalPage =0;

  showAlertDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
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
    scrollController.addListener(_scrollListener);
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
    getAccessGroup();
    getRequestOrder();
    getCheklistPending();
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
    var res = await Network().getData('sales_orders?page=$present&this_year=Y&select_by=status&select_query=${selectedFilter}');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        salesOrder.clear();
        resultData['data']['data'].forEach((detailData) {
          salesOrder.add(SalesOrder.fromJson(detailData));
        });
        perPage = resultData['data']['per_page'];
        totalPage = resultData['data']['total'];
      });
    }
  }

  void moreRequestOrder(page) async {
    var res = await Network().getData('sales_orders?page=$page&this_year=Y&select_by=status&select_query=${selectedFilter}');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        perPage = resultData['data']['per_page'];
        totalPage = resultData['data']['total'];

        resultData['data']['data'].forEach((detailData) {
          salesOrder.add(SalesOrder.fromJson(detailData));
        });
      });
    }
  }


  void getCheklistPending() async{
    var count = await _salesOrder.countSalesOrder();
    setState(() {
      count_pending = count;
    });

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
                          sheetApprove(Id,status);
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

  void sheetApprove(Id,status) {
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Update Lokasi', style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),)
                          ],
                        ),
                        SizedBox(height: 10,),
                        Image.asset(
                          "assets/images/no_image_pelaporan.png",
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                        SizedBox(height: 20,),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Apa anda yakin untuk approve sales order tersebut?',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
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
                              margin: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              height: 50,
                              width: size.width / 3,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(18)),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  updateSalesOrder(Id, status);
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

  void updateSalesOrder(Id, status) async{
    var data = {
      "status": status
    };
    showAlertDialog(context);
    var res = await Network().putUrl('sales_orders/$Id/update_status?show_type=test', data);
    var body = json.decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      await Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.pop(context);
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) {
              return new DialogPopUpSuccess(text: 'Sukses update sales order.',);
            },
            fullscreenDialog: true));
      });
      setState(() {
        status = "draft";
      });
      getRequestOrder();
    }
  }

  void openSalesOrderDetail(item) async{

    var res =
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new SalesOrderDetailScreen.add(item.id);
        },
        fullscreenDialog: true));

    if(res == 'success'){
      getRequestOrder();
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) {
            return new DialogPopUpSuccess(text: 'Sukses update sales order.',);
          },
          fullscreenDialog: true));
    }
  }

  void submitPending() async {
    bool is_done = false;

    showAlertDialog(context);
    var data = await _salesOrder.getSalesOrder();

    for(var result in data){

      var data = {
        "tenant_id": result['tenant_id'],
        "location_id": result['location_id'],
        "customer_id": result['customer_id'],
        "contact_id": null,
        "emergency_contact_id": null,
        "primary_product_id": result['primary_product_id'],
        "code" : result['code'],
        "name":result['name'],
        "is_inquiry" : false, // Harus diisi dengan nilai false
        "has_contract" : false, // Harus diisi dengan nilai true
        "is_renewal" : false, // Harus diisi dengan nilai false
        "status" : result['status'],
        "renewal_status" : result['renewal_status'], // Harus diisi dengan nilai on renewal
        "started_at" : result['started_at'], // Isian dari user dan harus diisi
        "ended_at" : result['ended_at'], // Isian dari user dan harus diisi
        "signed_at" : result['signed_at'], // Isian dari user dan harus diisi
        "term" : result['term'], // Harus diisi dan diambil dari konfigurasi product
        "term_of_payment" : result['term_of_payment'], // Harus diisi dengan nilai anually
        "term_notice_period" : result['term_notice_period'], // Harus diisi dengan nilai 3
        "tax_percentage" : result['tax_percentage'], // Diambil dari postman login di bagian tenant
        "length_of_term" : result['length_of_term'], // Isian dari user dan harus diisi
        "total_cost" : 0, // Harus diisi dengan nilai 0
        "total_price" : result['total_price'], // Harus diisi dengan nilai sesuai pilihan produk yang di kali dengan length of term dan di kali dengan quantity
        "total_discount" : result['total_discount'], // Harus diisi dengan nilai 0
        "total_tax" : result['total_tax'],
        "sales_order_details": await getDetails(result['id']),
        'drafted_by': result['drafted_by']
      };

      final res = await Network().postUrl('sales_orders', data);
      var body = json.decode(res.body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        var res = await _salesOrder.updateSalesOrder(result['id'], 1);
        is_done = true;
        // deleteAll(result['id']);
      }else{
        is_done = false;
        var res = await _salesOrder.updateSalesOrder(result['id'], 0);
      }
    }

    if(is_done == true){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text('Sukses Update Checklist pending'),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'x',
            onPressed: () {
              // Code to execute.
            },
          ),
          duration: Duration(seconds: 3),
          shape: StadiumBorder(),
          margin: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),
      );
      loadUserData();
    }
  }

  getDetails(Id) async{
    var list_detail = [];
    var data = await _salesOrder.getSalesOrderDetail(Id);
    list_detail.clear();
    for(var items in data){
      list_detail.add({
        'sales_order_id': '',
        'product_id': items['product_id'],
        'customer_complimentary_id': null,
        'complimentary_id': null,
        'asset_type_id': null,
        'asset_id': items['asset_id'],
        'room_id': null,
        'name': items['name'],
        'type': 'charged',
        'has_complimentary':0,
        'has_term': 0,
        'is_repeated_in_term': 0,
        'has_quantity' : 1,
        'term': 'no term',
        'repeated_term': 'no term',
        'started_at': items['started_at'],
        'ended_at': items['ended_at'],
        'length_of_term': 1,
        'quantity': items['quantity'],
        'total_use_of_complimentary':0,
        'cost': 0,
        'price': items['price'],
        'discount': items['discount'],
        'service_charge': items['service_charge'],
        'tax': items['tax'],
      });
    }
    return list_detail;
  }

  Future<void> _scrollListener() async{

    if(scrollController.position.pixels == scrollController.position.maxScrollExtent){

      setState(() {
        isLoadingMore = true;
      });
      loadMore();

    }
  }
  Future<void> loadMore() async{

    setState(() {

      if(present != totalPage) {
        present += 1;
        moreRequestOrder(present);
      }
      isLoadingMore = false;
    });
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
          loadUserData();
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
            GestureDetector(
              onTap: (){
                submitPending();
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.blueAccent, shape: BoxShape.circle),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(
                            'Sales order Pending',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        count_pending.toString(),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: salesOrder.length,
                  itemBuilder: (context, index) {
                    var item = salesOrder[index];
                    return GestureDetector(
                      onTap: () {
                        openSalesOrderDetail(item);
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
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
                                  Text('Sales Order',
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
                              currencyFormat((int.parse(item.totalPrice.toString()) - int.parse(item.totalDiscount.toString()) ) + int.parse(item.totalTax.toString()) + int.parse(item.totalServiceCharge.toString())),
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
            ),
            if(isLoadingMore == true)
              Padding(
                padding: EdgeInsets.only(top: 10,bottom: 20),
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
                return new FormSalesOrderScreen();
              },
              fullscreenDialog: true));

          if (res == 'success') {

            loadUserData();
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) {
                  return new DialogPopUpSuccess(text: 'Sukses tambah sales order.',);
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
