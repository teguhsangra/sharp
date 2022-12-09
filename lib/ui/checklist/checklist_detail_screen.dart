import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:telkom/ui/home/home_screen.dart';
import '../../components/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telkom/constants.dart';
import 'package:telkom/model/checklist_result.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geocoding/geocoding.dart';

class ChecklistResultDetailScreen extends StatefulWidget {
  final int checklistId;

  const ChecklistResultDetailScreen({Key? key, required this.checklistId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CheckLisDetailState();
}

class CheckLisDetailState extends State<ChecklistResultDetailScreen> {
  bool isLoading = true;
  var user = {};
  late ChecklistResult checklistResult;
  var allotnmentName = '';
  double _latitude = 0;
  double _longitude = 0;
  bool isOutArea = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    getDetail(widget.checklistId);
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Center(
              child: new SizedBox(
                height: 50.0,
                width: 50.0,
                child: new CircularProgressIndicator(
                  value: null,
                  strokeWidth: 7.0,
                ),
              ),
            ),
            new Container(
              margin: const EdgeInsets.only(top: 25.0),
              child: new Center(
                child: new Text(
                  "loading.. wait...",
                  style: new TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var userSession = jsonDecode(localStorage.getString('user').toString());

    setState(() {
      user = userSession;
    });
  }

  void getDetail(int checklistId) async {
    try {
      isLoading = true;
      var res = await Network().getData('checklist_results/$checklistId');
      if (res.statusCode == 200) {
        var resultData = jsonDecode(res.body);

        setState(() {
          checklistResult = ChecklistResult.fromJson(resultData['data']);

          checklistResult.isChecked = 1;

          // Jangan lupa kodingan ini dilengkapin @Teguh
          checklistResult.employeeId = user['person']['employee']['id'];
          var dateNow = formatDate("yyyy-mm-dd hh:mm", DateTime.now());

          if (DateTime.parse(checklistResult.endedAt.toString())
              .isAfter(DateTime.parse(dateNow))) {
            checklistResult.isOverdue = 1;
          }
          // print();
        });
      }
    } finally {
      isLoading = false;
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //location service not enabled, don't continue

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location service Not Enabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }
    //permission denied forever
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permission denied forever, we cannot access',
      );
    }
    //continue accessing the position of device
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _getLocationLatLong() async {
    Position position = await _getGeoLocationPosition();
    isLoading = true;
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
    isLoading = false;
  }

  calculate() async {
    double calculateDistance(latFirst, longFirst, latSecond, longSecond) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((latSecond - latFirst) * p) / 2 +
          c(latFirst * p) *
              c(latSecond * p) *
              (1 - c((longSecond - longFirst) * p)) /
              2;
      return 12742 * asin(sqrt(a));
    }

    var person = user['person'];
    var employee = person['employee'];
    var location = employee['locations'];
    var tenant = user['tenant'];
    var toleranceDistance =
    user['tenant']['latlong_tolerance_distance_in_meter'];
    bool outOfArea = true;

    double totalDistance = 0;

    for (var item in location) {
      totalDistance = calculateDistance(
          _latitude, _longitude, item['latitude'], item['longitude']);

      if (totalDistance * 1000 > toleranceDistance) {
        // outOfArea = true;
        // break;
      }
      outOfArea = false;
    }
    setState(() {
      isOutArea = outOfArea;
    });
  }

  _getFromGallery(checklistResultContent) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      var file_image = File(pickedFile.path);
      // Get mime type
      final _image = await file_image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: _image);
      // convert to base64
      Uint8List? imagebytes = await file_image.readAsBytes();
      String base64string = base64.encode(imagebytes!);

      setState(() {
        checklistResultContent.picturePath =
            "data:" + mime.toString() + ";base64," + base64string;
      });
    }
  }

  /// Get from Camera
  _getFromCamera(checklistResultContent) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      var file_image = File(pickedFile.path);
      // Get mime type
      final _image = await file_image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: _image);
      // convert to base64
      Uint8List? imagebytes = await file_image.readAsBytes();
      String base64string = base64.encode(imagebytes!);

      setState(() {
        checklistResultContent.picturePath =
            "data:" + mime.toString() + ";base64," + base64string;
      });
    }
  }

  void fillRadioValue(
      checklistResultContent, checklistResultContentAnswerOptions, item) async {
    setState(() {
      for (var detailAnswer in checklistResultContentAnswerOptions) {
        if (item == detailAnswer.name) {
          checklistResultContent.answer = item;

          if (detailAnswer.isNormalAnswer != 1) {
            checklistResultContent.isAbnormal = 1;

            checklistResult.hasAbnormalAnswer = 1;
          } else {
            checklistResultContent.isAbnormal = 0;

            checklistResult.hasAbnormalAnswer = 0;
          }

          break;
        }
      }
    });
  }

  void submitChecklist() async {
    bool isSubmit = true;
    bool isLoadingSubmit = true;
    var contents = [];
    for (var content in checklistResult.checklistResultContents) {
      if (content.answer == null) {
        isSubmit = false;
        isLoadingSubmit = false;
      }

      if (content.hasPhoto == 1) {
        if (content.picturePath == null) {
          isSubmit = false;
          isLoadingSubmit = false;
        }
      }

      contents.add({
        "id": content.id,
        "tenant_id": content.tenantId,
        "checklist_result_id": content.checklistResultId,
        "name": content.name,
        "type": content.type,
        "unit": content.unit,
        "has_photo": content.hasPhoto,
        "min_value": content.minValue,
        "max_value": content.maxValue,
        "answer": content.answer,
        "picture_path": content.picturePath,
        "is_abnormal": content.isAbnormal,
        "checklist_result_content_answer_options":
            jsonEncode(content.checklistResultContentAnswerOptions)
      });
    }

    var data = {
      "tenant_id": user['tenant_id'],
      "checklist_id": checklistResult.checklist?.id,
      "employee_id": user['person']['employee']['id'],
      "customer_id": checklistResult.customerId,
      "asset_id": checklistResult.assetId,
      "room_id": checklistResult.roomId,
      "floor_id": null,
      "location_id": checklistResult.locationId,
      "allotment": "room",
      "is_checked": checklistResult.isChecked,
      "period": checklistResult.period,
      "started_at": checklistResult.startedAt.toString(),
      "ended_at": checklistResult.endedAt.toString(),
      "filled_at": formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()),
      "has_abnormal_answer": checklistResult.hasAbnormalAnswer,
      "is_unfilled": 1,
      "is_overdue": checklistResult.isOverdue,
      "timezone": checklistResult.timezone,
      "asset": null,
      "checklist_result_contents": contents
    };

    if (isSubmit) {
      if (isLoadingSubmit) {
        if (isOutArea) {
          // Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Mohon maaf anda sedang tidak dalam lokasi',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            shape: StadiumBorder(),
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            action: SnackBarAction(
              textColor: Colors.white,
              label: 'x',
              onPressed: () {
                // Code to execute.
              },
            ),
          ));
        }else{
          showAlertDialog(context);
          var res = await Network()
              .postCheckOut('checklist_results/${widget.checklistId}', data);
          var body = json.decode(res.body);
          if (res.statusCode == 201 || res.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: const Text('Sukses update checklist'),
                action: SnackBarAction(
                  textColor: Colors.white,
                  label: 'x',
                  onPressed: () {
                    // Code to execute.
                  },
                ),
                duration: Duration(seconds: 3),
                shape: StadiumBorder(),
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                behavior: SnackBarBehavior.floating,
                elevation: 0,
              ),
            );
            Navigator.of(
              context,
            ).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
                    (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: const Text('Gagal submit checklist'),
                action: SnackBarAction(
                  textColor: Colors.white,
                  label: 'x',
                  onPressed: () {
                    // Code to execute.
                  },
                ),
                duration: Duration(seconds: 3),
                shape: StadiumBorder(),
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                behavior: SnackBarBehavior.floating,
                elevation: 0,
              ),
            );
          }
        }

      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Checklist or evidence harus di isi',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        shape: StadiumBorder(),
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'x',
          onPressed: () {
            // Code to execute.
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFA4A0C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Checklist Detail"),
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
                icon: Icon(Icons.notifications, color: Colors.white),
              )),
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
              )),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(children: [
        Expanded(
          child: (isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  scrollDirection: Axis.vertical,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          checklistResult.checklist!.name,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontStyle: FontStyle.normal),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            allotnmentName,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        if (checklistResult.period == 'hour')
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              'Waktu: ' +
                                  formatDate(
                                      'HH:mm', checklistResult.startedAt) +
                                  ' - ' +
                                  formatDate('HH:mm', checklistResult.endedAt),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            checklistResult.location!.address,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        Divider(color: Colors.grey),
                        checklistContent(),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          height: 50,
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                              color: Color(0xFFFA4A0C),
                              borderRadius: BorderRadius.circular(20)),
                          child: TextButton(
                            onPressed: () {
                              calculate();
                              submitChecklist();
                            },
                            child: const Text(
                              'Submit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        )
                      ]),
                )),
        ),
      ]),
    );
  }

  Container checklistContent() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: getListContent(),
      ),
    );
  }

  List<Column> getListContent() {
    List<Column> list = <Column>[];

    for (var checklistResultContent
        in checklistResult.checklistResultContents) {
      switch (checklistResultContent.type) {
        case "radio":
          list.add(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(checklistResultContent.name.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal)),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Container(
                    width: 300,
                    child: Text(
                        "Standar : " + checklistResultContent.unit.toString(),
                        softWrap: true,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontStyle: FontStyle.normal)),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: getAnswer(checklistResultContent,
                          checklistResultContent.type, null),
                    ),
                    if (checklistResultContent.hasPhoto == 1)
                      picture(checklistResultContent)
                  ],
                ),
              ),
              Divider(color: Colors.black),
              SizedBox(
                height: 10,
              )

              // picture(checklistContent.hasPhoto!.toInt())
            ],
          ));
          break;
        case "short text":
          // Ngoding disesi berikutnya
          break;
        case "long text":
          // Ngoding disesi berikutnya
          break;
        case "checkbox":
          // Ngoding disesi berikutnya
          break;
        case "range in number":
          // Ngoding disesi berikutnya
          break;
      }
    }
    return list;
  }

  Widget picture(var checklistResultContent) {
    Size size = MediaQuery.of(context).size;
    var image;

    if (checklistResultContent.picturePath == null) {
      image = null;
    } else {
      var path = checklistResultContent.picturePath.split(',')[1];
      Uint8List bytes = base64.decode(path);

      image = bytes;
    }

    return Container(
        child: checklistResultContent.picturePath == null
            ? Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Evidence',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, StateSetter setState) {
                                return Container(
                                  width: size.width,
                                  height: size.height * 0.3,
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 50.0,
                                            height: 5.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Text('Evidence',
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black)),
                                        const SizedBox(height: 20.0),
                                        GestureDetector(
                                          onTap: () async {
                                            _getFromCamera(
                                                checklistResultContent);
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.photo_camera,
                                                color: Color(0XFFFA4A0C),
                                                size: 28,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                'Take from camera',
                                                style: TextStyle(fontSize: 16),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            });
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6ECF6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              color: Color(0XFFFA4A0C),
                              size: 28,
                            ),
                          ),
                          Text('Take a picture',
                              style: TextStyle(
                                fontSize: 14,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Evidence',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FullScreenWidget(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          image,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, StateSetter setState) {
                                return Container(
                                  width: size.width,
                                  height: size.height * 0.3,
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 50.0,
                                            height: 5.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Text('Evidence',
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black)),
                                        const SizedBox(height: 20.0),
                                        GestureDetector(
                                          onTap: () async {
                                            _getFromCamera(
                                                checklistResultContent);
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.photo_camera,
                                                color: Color(0XFFFA4A0C),
                                                size: 28,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                'Take from camera',
                                                style: TextStyle(fontSize: 16),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 40.0),

                                      ],
                                    ),
                                  ),
                                );
                              });
                            });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                        color: Color(0xFFFA4A0C),
                        child: const SizedBox(
                          width: 100,
                          height: 40,
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                  TextSpan(
                                      text: ' foto ulang',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          checklistResultContent.picturePath = null;
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                        color: Color(0xFFFA4A0C),
                        child: const SizedBox(
                          width: 100,
                          height: 40,
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                  TextSpan(
                                      text: ' Hapus foto ',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )));
  }

  Widget getAnswer(var checklistResultContent, var type, answer) {
    List<ListTile> list = <ListTile>[];
    List<String> answerOptions = <String>[];
    String selectedValue = '';

    if (answer != null) {
      selectedValue = answer;
    }

    switch (type) {
      case "radio":
        for (var answerOption
            in checklistResultContent.checklistResultContentAnswerOptions) {
          list.add(ListTile(
              title: Text(answerOption.name.toString()),
              leading: Radio(
                value: answerOption.name,
                groupValue: checklistResultContent.answer,
                onChanged: (value) {
                  fillRadioValue(
                      checklistResultContent,
                      checklistResultContent
                          .checklistResultContentAnswerOptions,
                      value);
                },
              )));
        }
        break;
      default:
        return Text("...");
    }
    return Column(
      children: list,
    );
  }
}
