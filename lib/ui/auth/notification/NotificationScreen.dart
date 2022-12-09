import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telkom/model/notification.dart';
import 'package:telkom/network/api.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> listData = [];
  List dataUnRead = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _getData();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  _getData() async {
    try {
      final res = await Network().getData('notifications');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          for (var i = 0; i < data['data'].length; i++) {
            listData.add(NotificationData.fromJson(data['data'][i]));
            if (data['data'][i]['is_read'] == 0) {
              dataUnRead.add(data['data'][i]['id']);
            }
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _readAll() async {
    print("data unread:$dataUnRead");
    if (dataUnRead.length > 0) {
      print('dataunread length' + dataUnRead.length.toString());
      try {
        final res = await Network().getData('notifications/read_all');

        if (res.statusCode == 200) {
          setState(() {
            listData = [];
            dataUnRead = [];
            _getData();
          });
        }
      } catch (e) {
        print(e);
      }
    } else {}
  }

  _clickNotif(index) async {
    int id = listData[index].id;
    print(id);
    bool next = false;
    for (var i = 0; i < dataUnRead.length; i++) {
      print(dataUnRead[i]);
      if (dataUnRead[i].toString() == id.toString()) {
        next = true;
        break;
      }
    }
    if (next) {
      try {
        final res =
            await Network().getData('notifications/' + id.toString() + '/read');

        if (res.statusCode == 200) {
          setState(() {
            listData = [];
            dataUnRead = [];
            _getData();
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text("Notifications",
          style: TextStyle(
              color: Colors.black
          ),),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _readAll(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.done_all,
                      size: 15,
                    ),
                    Text("Read All",
                        style: TextStyle(
                          fontSize: 12,
                            color: Colors.black
                        ))
                  ],
                ),
              )),
        ],
      ),
      body: isLoading ?
      Container(
        margin:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      )
          : listView(),
    );
  }

  Widget listView() {
    return ListView.separated(
        itemBuilder: ((context, index) => InkWell(
              onTap: () => _clickNotif(index),
              child: listViewItem(index),
            )),
        separatorBuilder: ((context, index) {
          return Divider(height: 0);
        }),
        itemCount: listData.length);
  }

  Widget listViewItem(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prefixIcon(index),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(index),
                  message(index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget prefixIcon(int index) {
    var item = listData[index];
    return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.is_read == 1
              ? Colors.grey.shade300
              : Colors.yellow.shade800),
      child: Icon(
        Icons.notifications,
        size: 25,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget message(int index) {
    var item = listData[index];
    return Container(
      child: RichText(
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: item.message.toString(),
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          )),
    );
  }

  Widget title(int index) {
    var item = listData[index];
    DateTime timestamp = (DateTime.parse(item.created_at));
    var created_at = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.title.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: item.is_read == 0 ? FontWeight.bold : FontWeight.w700,
              color: item.is_read == 0 ? Colors.black : Colors.grey,
            ),
          ),
          Text(
            created_at,
            style: TextStyle(
              fontSize: 10,
              color: item.is_read == 0 ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
