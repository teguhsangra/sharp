import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telkom/model/checklist.dart';
import 'package:telkom/model/checklist_result.dart';
import 'package:telkom/model/room.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/checklist/checklist_detail_is_checked_screen.dart';
import 'package:telkom/ui/checklist/checklist_screen_map.dart';

class ChecklistIsCheckedScreen extends StatefulWidget {
  const ChecklistIsCheckedScreen({super.key});

  @override
  State<StatefulWidget> createState() => ChecklistIsCheckedState();
}

class ChecklistIsCheckedState extends State<ChecklistIsCheckedScreen> {
  List<ChecklistResult> checklistResults = [];
  final listChecklist = <Checklist>[];
  final listRoom = <Room>[];
  var selectedIndexChecklist = null;
  var selectedIndexRoom = 0;
  var selectedNameRoom = null;
  bool isLoading = true;
  bool isFilter = false;
  bool isSubmitFilter = false;
  bool isSubmitListFilter = false;
  bool isListFilter = false;

  var allotmentName = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getChecklistResult();
    getChecklist();
    getRooms();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getChecklistResult() async {
    var res = await Network().getData('checklist_results?check_unfinish=N');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        checklistResults.clear();
        resultData['data'].forEach((v) {
          checklistResults.add(ChecklistResult.fromJson(v));
        });
      });
    }
  }

  void getChecklist() async {
    var res = await Network().getData('checklists');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        listChecklist.clear();
        resultData['data'].forEach((v) {
          listChecklist.add(Checklist.fromJson(v));
        });
      });
    }
  }

  void getRooms() async {
    var res = await Network().getData('rooms');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        listRoom.clear();
        resultData['data'].forEach((v) {
          listRoom.add(Room.fromJson(v));
        });
      });
    }
  }

  Future<void> loadResources() async {
    getChecklistResult();
    getChecklist();
    getRooms();
  }

  void filterChecklistResult() async {
    var checklist_id = '';
    var room_id = '';
    print(selectedIndexChecklist);
    if (selectedIndexChecklist != 0) {
      checklist_id = selectedIndexChecklist.toString();
    }
    if (selectedIndexRoom != 0) {
      room_id = selectedIndexRoom.toString();
    }
    var url = 'checklist_results?check_unfinish=N&checklist_id=' +
        checklist_id +
        '&room_id=' +
        room_id;
    print(url);
    var res = await Network().getData(
        'checklist_results?check_unfinish=N&checklist_id=' +
            checklist_id.toString() +
            '&room_id=' +
            room_id.toString());
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      // print(resultData['data']);
      setState(() {
        isSubmitFilter = false;
        checklistResults.clear();
        resultData['data'].forEach((v) {
          checklistResults.add(ChecklistResult.fromJson(v));
        });
      });
    }
  }

  void openBottomSheet() async {
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
          return BottomSheet(
            onClosing: () {},
            enableDrag: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Filter',
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black)),
                            if (isFilter == true)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndexChecklist = 0;
                                    selectedIndexRoom = 0;
                                    isFilter = false;
                                    isSubmitFilter = true;
                                  });
                                },
                                child: Text('Reset',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green)),
                              )
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Category',
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black)),
                            if (listChecklist.length > 3)
                              Text('Lihat Semua',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFA4A0C)))
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            // banyak grid yang ditampilkan dalam satu baris
                            crossAxisCount: 2,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 9),
                          ),
                          itemBuilder: (context, index) {
                            var item = listChecklist[index];

                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: ChoiceChip(
                                backgroundColor: Colors.grey,
                                selectedColor: Color(0xFFFA4A0C),
                                label: Text(
                                  item.name,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                selected: selectedIndexChecklist == item.id
                                    ? true
                                    : false,
                                onSelected: (bool value) {
                                  setState(() {
                                    if (value) {
                                      selectedIndexChecklist = item.id;
                                      isSubmitFilter = true;
                                      isFilter = true;
                                    } else {
                                      if (selectedIndexRoom != 0) {
                                        isSubmitFilter = true;
                                      } else {
                                        isSubmitFilter = false;
                                      }
                                      selectedIndexChecklist = 0;
                                    }
                                  });
                                },
                              ),
                            );
                          },
                          itemCount: listChecklist.length,
                        ),
                        SizedBox(height: 20.0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Room',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                              if (listRoom.length >= 3)
                                GestureDetector(
                                  onTap: () {
                                    roomBottomSheet();
                                  },
                                  child: Text('Lihat Semua',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFA4A0C))),
                                )
                            ]),
                        const SizedBox(height: 15.0),
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            // banyak grid yang ditampilkan dalam satu baris
                            crossAxisCount: 2,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 9),
                          ),
                          itemBuilder: (context, index) {
                            var item = listRoom[index];
                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: ChoiceChip(
                                backgroundColor: Colors.grey,
                                selectedColor: Color(0xFFFA4A0C),
                                label: Text(
                                  item.name,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                selected:
                                    selectedIndexRoom == item.id ? true : false,
                                onSelected: (bool value) {
                                  setState(() {
                                    if (value) {
                                      selectedIndexRoom = item.id;
                                      isSubmitFilter = true;
                                      isFilter = true;
                                    } else {
                                      if (selectedIndexChecklist != 0) {
                                        isSubmitFilter = true;
                                      } else {
                                        isSubmitFilter = false;
                                      }
                                      selectedIndexRoom = 0;
                                    }
                                  });
                                },
                              ),
                            );
                          },
                          itemCount: listRoom.length >= 3 ? 3 : 1,
                        ),
                        SizedBox(height: 50.0),
                        if (isSubmitFilter != false)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            height: 50,
                            width: size.width * 0.9,
                            decoration: BoxDecoration(
                                color: Color(0xFFFA4A0C),
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () {
                                filterChecklistResult();
                                Navigator.pop(context);
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
            },
          );
        }).whenComplete(() {
      // print('test');
      if (isSubmitFilter == false) {
        setState(() {
          selectedIndexChecklist = 0;
          selectedIndexRoom = 0;
          isFilter = false;
        });
      }
    });
  }

  void roomBottomSheet() async {
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
              height: size.height * 0.9,
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
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Room',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (isListFilter == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndexRoom = 0;
                                isFilter = false;
                                isSubmitFilter = false;
                                isSubmitListFilter = false;
                                isListFilter = false;

                                isSubmitListFilter = true;
                              });
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      height: 500.0,
                      child: ListView.builder(
                        itemCount: listRoom.length,
                        itemBuilder: (context, index) {
                          var item = listRoom[index];
                          return CheckboxListTile(
                            title: Text(listRoom[index].name),
                            value: selectedIndexRoom == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndexRoom = item.id;
                                  isSubmitFilter = true;
                                  isFilter = true;
                                  isSubmitListFilter = true;
                                  isListFilter = true;
                                } else {
                                  selectedIndexRoom = 0;
                                  isFilter = false;
                                  isSubmitFilter = false;
                                  isSubmitListFilter = false;
                                  isListFilter = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (isSubmitListFilter != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFFFA4A0C),
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isSubmitListFilter = false;
                            });
                            sortListRoom();
                            Navigator.pop(context);
                            openBottomSheet();
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
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

  void sortListRoom() async {
    if (selectedIndexRoom != null) {
      listRoom.sort((a, b) => a.id.compareTo(selectedIndexRoom));

      int indexToRemove =
          listRoom.indexWhere((element) => element.id == selectedIndexRoom);

      var removedItem = listRoom.removeAt(indexToRemove);
      listRoom.insert(0, removedItem);
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
          "Checklist",
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
              icon: Icon(Icons.notifications, color: Color(0XFFFA4A0C)),
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
      )
          :
      RefreshIndicator(
          onRefresh: () async {
            await loadResources();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        openBottomSheet();
                      },
                      child: Container(
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0XFFFA4A0C)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              color: Color(0XFFFA4A0C),
                              size: 20,
                            ),
                            Text(' Filter '),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Column(children: getListData(checklistResults)),
              ],
            ),
          )),
    );
  }

  List<InkWell> getListData(List<ChecklistResult> listOfChecklistResult) {
    Size size = MediaQuery.of(context).size;
    List<InkWell> list = <InkWell>[];

    list.add(
      InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) {
                  return ChecklistMapScreen();
                }),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0XFFFA4A0C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    Icons.map,
                    color: Color(0XFFFA4A0C),
                    size: 25,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Checklist Map',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(width: size.width / 5),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Open Map',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );

    for (ChecklistResult detailChecklistResult in listOfChecklistResult) {
      allotmentName = ((detailChecklistResult.room != null)
          ? detailChecklistResult.room?.name
          : '')!;

      allotmentName =
          '${detailChecklistResult.checklist?.name} : \n$allotmentName';
      list.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) {
                  return ChecklistResultDetailIsCheckedScreen(
                      checklistId: detailChecklistResult.id);
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
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Color(0xFFFA4A0C), shape: BoxShape.circle),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      allotmentName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
      );
    }
    return list;
  }
}
