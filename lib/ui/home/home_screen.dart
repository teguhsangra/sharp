import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/dialog_pop_up_success_check_in.dart';
import 'package:telkom/components/dialog_pop_up_success_check_out.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/components/menu_widget.dart';
import 'package:telkom/ui/asset/asset_screen.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/auth/profile/profile_screen.dart';
import 'package:telkom/ui/competitor/compotior_activity_screen.dart';
import 'package:telkom/ui/competitor/compotior_info_screen.dart';
import 'package:telkom/ui/dashboard/dashboard_screen.dart';
import 'package:telkom/ui/dashboard/presensi_screen.dart';
import 'package:telkom/ui/feedback/feedback_screen.dart';
import 'package:telkom/ui/report/report_screen.dart';
import 'package:unicons/unicons.dart';

import '../../network/api.dart';

class HomeScreenTwo extends StatefulWidget {
  const HomeScreenTwo(BuildContext context, {super.key});

  @override
  State<StatefulWidget> createState() => HomeStateTwo();
}

class HomeStateTwo extends State<HomeScreenTwo> {
  int counter = 0;
  var user = {};
  int totalIsChecked = 0;
  int totalIsNotChecked = 0;
  int totalRequestOrder = 0;
  int totalApprovedRequestOrder = 0;
  bool isLoading = true;
  var locationName = '';
  double _latitude = 0;
  double _longitude = 0;
  int point_fee = 0;
  int sell_unit = 0;
  bool checkin = false;
  var unSignout = {};
  int index = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    loadAllData();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadResources() async {
    loadUserData();
    getLocationLatLong();
    getNotificationUnread();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Container(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xffD9D9D9),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      "assets/images/hero_profile.png",
                      height: 24.0,
                      width: 24.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Row(children: [
                // Text(greeting(1),
                //   style: TextStyle(fontSize: 18, color: Colors.black),
                // ),
                Text(
                  ' ${user['name']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ]),
            ],
          ),
        ),
        actions: [
          Stack(
            children: <Widget>[
              new IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationScreen()),
                    );
                  }),
              counter != 0
                  ? new Positioned(
                      right: 11,
                      top: 11,
                      child: new Container(
                        padding: EdgeInsets.all(2),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          counter >= 9 ? '9 +' : '$counter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : new Container()
            ],
          )
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          loadResources();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: isLoading
              ? Column(
                  children: [
                    CardSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                    ),
                    CardSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                    ),
                    CardSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                    ),
                    CardPageSkeleton(
                      totalLines: 1,
                    )
                  ],
                )
              : Column(
                  children: [
                    cardAddressLocation(),
                    cardCheckInCheckout(),
                    cardTarget(),
                    cardMenu(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget cardAddressLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/my_location.png",
              height: 24.0,
              width: 24.0,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(locationName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(color: Colors.black, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget cardCheckInCheckout() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 1,
                  // Shadow position
                  spreadRadius: 1,
                  offset: const Offset(0, 1)),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkin ? "Berhasil Absen pada" : "Masuk untuk absen ",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                Text(
                  formatDate('dd MMMM yyyy', DateTime.now()),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
                checkin
                    ? Text(
                        formatDate(
                            'HH:mm:ss',
                            unSignout.length > 0
                                ? DateTime.tryParse(unSignout['sign_in_at'])
                                : DateTime.now()),
                        style: TextStyle(color: Colors.black, fontSize: 10))
                    : Text('')
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    checkin ? checkOutDialog() : checkInDialog();
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 0,
                    color: const Color(0xFFE50404),
                    child: SizedBox(
                      width: size.width / 4,
                      height: 40,
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: checkin ? 'Check-Out' : ' Check-in',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  loadAllData() async {
    loadUserData();
    getNotificationUnread();
    getLocationLatLong();
  }

  loadUserData() async {
    var res = await Network().getData('me');
    var body = json.decode(res.body);
    if (res.statusCode == 200 || res.statusCode == 200) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var userSession = jsonDecode(localStorage.getString('user').toString());

      setState(() {
        point_fee = body['data']['user']['person']['employee']['point_fee'];
        sell_unit = body['data']['user']['person']['employee']['money_fee'];
        user = userSession;
      });
    }

    checkUnSignOut();

    checkerTodayResume();
  }

  checkUnSignOut() async {
    var res = await Network().getData(
        'check_unsignout?employee_id=${user['person']['employee']['id']}');
    if (res.statusCode == 401) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.clear();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen()));
    } else {
      var body = json.decode(res.body);
      var data_body = body['data'];

      if (data_body != null) {
        setState(() {
          if (data_body?['sign_out_at'] == null) {
            checkin = false;
          }
          unSignout = data_body;
          checkin = true;
        });
      }
    }
  }

  checkerTodayResume() async {
    var res = await Network().getData(
        'checker-today_resume?date_range_filter_by=started_at&started_at=' +
            formatDate('yyyy-MM-dd', DateTime.now()) +
            '&ended_at=' +
            formatDate('yyyy-MM-dd', DateTime.now()));
    if (res.statusCode == 401) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.clear();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen()));
    } else {
      var result = jsonDecode(res.body);

      setState(() {
        totalIsChecked = result['data']['total_is_checked'];
        totalIsNotChecked = result['data']['total_is_not_checked'];
        totalRequestOrder = result['data']['total_request_order'];
        totalApprovedRequestOrder =
        result['data']['total_approved_request_order'];
      });
    }
  }


  getNotificationUnread() async {
    var res = await Network().getData('notifications/get_total_unread');
    var body = json.decode(res.body);
    var data_body = body['data'];
    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        counter = data_body;
      });
    }
  }

  Future<void> getLocationLatLong() async {
    Position position = await getGeoLocationPosition();

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
    if (user != null) {
      var date = formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now());

      var data = {
        "last_latitude": position.latitude,
        "last_longitude": position.longitude,
        "last_position_at": date
      };

      var res = await Network().postLastPosition(
          'employees-last-position/${user['person']['employee']['id']}', data);
      var body = json.decode(res.body);
    }
    getAddressFromLongLat(position);
  }

  Future<Position> getGeoLocationPosition() async {
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

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    setState(() {
      locationName = '${place.street},${place.locality}';
    });
  }

  Future checkInDialog() async {
    var res = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new PresensiScreen();
    }));

    if (res == 'success') {
      setState(() {
        checkin = true;
      });
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) {
            return const DialogPopUpSuccessCheckIn();
          },
          fullscreenDialog: true));
      checkUnsignout();
    }
  }

  Future checkOutDialog() async {
    var res = await Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new PresensiScreen(unSignout: unSignout);
    }));
    if (res == 'success') {
      setState(() {
        checkin = false;
      });
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) {
            return const DialogPopUpSuccessCheckOut();
          },
          fullscreenDialog: true));
      checkUnsignout();
    }
  }

  checkUnsignout() async {
    var res = await Network().getData(
        'check_unsignout?employee_id=${user['person']['employee']['id']}');
    if (res.statusCode == 401) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.clear();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen()));
    } else {
      var body = json.decode(res.body);
      var data_body = body['data'];

      if (data_body != null) {
        setState(() {
          if (data_body?['sign_out_at'] == null) {
            checkin = false;
          }
          unSignout = data_body;
          checkin = true;
        });
      }
    }
  }

  Widget cardTarget() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 1,
                    // Shadow position
                    spreadRadius: 1,
                    offset: const Offset(0, 1)),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Target",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pencapaian",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        point_fee.toString(),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      const Text(
                        "Point",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(width: 100),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Target",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        sell_unit.toString(),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      const Text(
                        "Unit Terjual",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ],
          )),
    );
  }

  Widget cardMenu() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 1,
                    // Shadow position
                    spreadRadius: 1,
                    offset: const Offset(0, 1)),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tools",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MenuWidget(
                    icon: "assets/images/ic_inventory.png",
                    text: "Data Barang",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AssetScreen()),
                      );
                    },
                  ),
                  MenuWidget(
                    icon: "assets/images/ic_stock.png",
                    text: "Stok Barang",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                  selectedTab: 2,
                                )),
                      );
                    },
                  ),
                  MenuWidget(
                    icon: "assets/images/ic_analytics.png",
                    text: "Report",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReportScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MenuWidget(
                    icon: "assets/images/ic_competitor_info.png",
                    text: "Competitor info",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CompetitorInfoScreen()),
                      );
                    },
                  ),
                  MenuWidget(
                    icon: "assets/images/ic_competitor_act.png",
                    text: "Competitor \n Activity",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CompetitorActivityScreen()),
                      );
                    },
                  ),
                  MenuWidget(
                    icon: "assets/images/ic_feedback.png",
                    text: "Feedback",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FeedbackScreen()),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          )),
    );
  }
}
