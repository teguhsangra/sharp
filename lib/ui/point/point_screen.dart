import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/model/sales_order.dart';
import 'package:telkom/model/sales_reward.dart';
import 'package:telkom/network/api.dart';
import 'package:intl/intl.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<StatefulWidget> createState() => PointState();
}

class PointState extends State<PointScreen> {
  bool isLoading = true;
  var user = {};
  List<SalesReward> listData = [];

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
    _getData();
  }

  _getData() async {
    try {
      final res = await Network().getData(
          'sales_reward_activities?employee_id=${user['person']['employee']['id']}&order_by=created_at&sort_by=DESC');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          listData.clear();
          for (var i = 0; i < data['data'].length; i++) {
            listData.add(SalesReward.fromJson(data['data'][i]));
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: const Text(
          "Point",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [],
        elevation: 0,
      ),
      body: isLoading
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: const Center(child: CircularProgressIndicator()),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _getData();
              },
              child: Column(
                children: [
                  Expanded(
                      child: ListView.separated(
                          separatorBuilder: ((context, index) {
                            return const Divider(height: 0);
                          }),
                          itemCount: listData.length,
                          itemBuilder: (context, index) {
                            var item = listData[index];
                            return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                item.mode == "income" ?
                                                const Icon(
                                                  Icons.login,
                                                  color: Colors.green,
                                                  size: 24,
                                                ) :
                                                const Icon(
                                                  Icons.logout,
                                                  color: Colors.red,
                                                  size: 24,
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 0,
                                                            right: 0,
                                                            top: 0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                item.mode
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Text(
                                                                " (${item.type})"),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 0,
                                                                  bottom: 0,
                                                                  right: 0,
                                                                  top: 5),
                                                          //apply padding to some sides only
                                                          child: Text(
                                                              DateFormat(
                                                                      'dd/MM/yyyy HH:mm')
                                                                  .format(DateTime
                                                                      .parse(item
                                                                          .created_at
                                                                          .toString())),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.grey,
                                                              )),
                                                        )
                                                      ],
                                                    ))
                                              ],
                                            ),
                                            Row(children: [
                                              Text(item.total_reward.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  )),
                                            ])
                                          ])
                                    ]));
                          })),
                ],
              ),
            ),
    );
  }
}
