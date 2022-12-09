import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:telkom/components/card.dart';
import 'package:telkom/ui/checklist/checklist_is_checked_screen.dart';
import 'package:telkom/ui/checklist/checklist_screen.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/auth/profile/profile_screen.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/constants.dart';
import 'package:telkom/components/CustomPageRoute.dart';
import 'package:telkom/ui/request_order/request_order_screen.dart';
import '../../components/helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geocoding/geocoding.dart';
import 'package:telkom/ui/home/presensi_screen.dart';
import 'package:loader_skeleton/loader_skeleton.dart';

class HomeScreen extends StatefulWidget {
  bool checkin;

  HomeScreen({
    Key? key,
    this.checkin = false,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(checkin);
}

class _HomeScreenState extends State<HomeScreen> {
  late LocationSettings locationSettings;

  bool isLoading = true;
  var user = {};
  int totalIsChecked = 0;
  int totalIsNotChecked = 0;
  int totalRequestOrder = 0;
  int totalApprovedRequestOrder = 0;
  bool checkin = false;
  int index = 0;
  double _latitude = 0;
  double _longitude = 0;
  bool _isMockLocation = false;
  var unSignout = {};
  var locationName = '';
  int counter = 0;
  _HomeScreenState(this.checkin);

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

  loadAllData() async {
    loadUserData();
    getNotifUnread();
    _getLocationLatLong();
  }

  Future<void> loadResources() async {
    loadUserData();
    _getLocationLatLong();
    getNotifUnread();
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

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
    if(user != null){
      var date = formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now());

      var data = {
        "last_latitude": position.latitude,
        "last_longitude": position.longitude,
        "last_position_at":date
      };

      var res = await Network().postLastPosition('employees-last-position/${user['person']['employee']['id']}', data);
      var body = json.decode(res.body);


    }
    getAddressFromLongLat(position);
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    setState(() {
      locationName = '${place.street},${place.locality},${place.country}';
    });
  }

  loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var userSession = jsonDecode(localStorage.getString('user').toString());

    setState(() {
      user = userSession;
    });

    checkUnsignout();

    checkerTodayResume();
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

  getNotifUnread() async{
    var res = await Network().getData('notifications/get_total_unread');
    var body = json.decode(res.body);
    var data_body = body['data'];
    if(res.statusCode == 200 || res.statusCode == 201)
    {
      setState(() {
        counter = data_body;
      });
    }
  }



  void _onItemTapped(int selectedIndex) {
    setState(() {
      index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: index,
        children: [
          HomeIndex(context),
          const ChecklistScreen(),
          const RequestOrderScreen(),
          const ProfileScreen()
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: GNav(
            color: const Color(0xFFFA4A0C),
            activeColor: const Color(0xFFFA4A0C),
            gap: 8,
            tabBackgroundColor: const Color(0XFFFDF0D2),
            padding: const EdgeInsets.all(15),
            iconSize: 20,
            selectedIndex: index,
            onTabChange: (int selectedIndex) {
              setState(() {
                index = selectedIndex;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.checklist, text: 'Checklist'),
              GButton(icon: Icons.request_page_outlined, text: 'Request Order'),
              GButton(icon: Icons.settings, text: 'Settings')
            ]),
      ),
    );
  }

  Widget HomeIndex(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        await loadResources();
      },
      child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        "assets/images/login_header.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(children: [
                                    const TextSpan(
                                      text: "Hi,",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    const TextSpan(text: '\n'),
                                    TextSpan(
                                      text: '${user['name']}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ]),
                                ),
                                Column(
                                  children: [
                                    Stack(
                                      children: <Widget>[
                                        new IconButton(icon: Icon(Icons.notifications, color: Colors.white,), onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const NotificationScreen()),
                                          );
                                        }),
                                        counter != 0 ? new Positioned(
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
                                              '$counter',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ) : new Container()
                                      ],
                                    )
                                   ,
                                    GestureDetector(
                                      onTap: () {
                                        _onItemTapped(3);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            const Color(0xffD9D9D9),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: ClipOval(
                                              child: Image.asset(
                                            "assets/images/hero_profile.png",
                                            height: 65.0,
                                            width: 49.0,
                                          )),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Color(0XFFFA4A0C),
                                  size: 20,
                                ),
                                SizedBox(
                                  width: size.width / 2,
                                  child: Text(
                                      locationName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12)
                                  )
                                  ,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isLoading
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
                        // Card Absensi
                        (checkin
                            ? CardContainer(
                                height: 120,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.access_alarm,
                                                color: Color(0XFFFA4A0C),
                                                size: 35,
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: size.width / 20),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Presensi',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(height: 20.0),
                                              Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      30.0),
                                                ),
                                                elevation: 0,
                                                color:
                                                const Color(0xFFE6ECF6),
                                                child: SizedBox(
                                                  width: size.width / 3.5,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: <
                                                            InlineSpan>[
                                                          WidgetSpan(
                                                            alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                            child: Icon(
                                                              Icons
                                                                  .directions_walk,
                                                              color: Color(
                                                                  0XFFFA4A0C),
                                                              size: 12,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                              ' Check-in: ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                  10)),
                                                          TextSpan(
                                                              text: formatDate(
                                                                  'HH:mm:ss',
                                                                  unSignout.length >
                                                                      0
                                                                      ? DateTime.tryParse(unSignout[
                                                                  'sign_in_at'])
                                                                      : DateTime
                                                                      .now()),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                  10)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: size.width / 30),
                                          Column(
                                            children: [
                                              Text(
                                                formatDate('dd MMMM yyyy',
                                                    DateTime.now()),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(height: 20.0),
                                              GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    CustomPageRoute(
                                                        child: PresensiScreen(
                                                          latitude: _latitude,
                                                          longitude: _longitude,
                                                          username:
                                                              user['name'],
                                                          tenant_id:
                                                              user['tenant_id'],
                                                          unSignout: unSignout,
                                                        ),
                                                        direction:
                                                            AxisDirection.left),
                                                  );
                                                },
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                  elevation: 0,
                                                  color:
                                                      const Color(0xFFE6ECF6),
                                                  child: SizedBox(
                                                    width: size.width / 4,
                                                    height: 40,
                                                    child: Center(
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: <
                                                              InlineSpan>[
                                                            WidgetSpan(
                                                              alignment:
                                                                  PlaceholderAlignment
                                                                      .middle,
                                                              child: Icon(
                                                                Icons
                                                                    .exit_to_app,
                                                                color: Color(
                                                                    0XFFFA4A0C),
                                                                size: 13,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                                text:
                                                                    ' Check out',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10)),
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
                                    )
                                  ],
                                ))
                            : CardContainer(
                                height: 120,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'Presensi',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(height: 20.0),
                                              Icon(
                                                Icons.access_alarm,
                                                color: Color(0XFFFA4A0C),
                                                size: 35,
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                formatDate('dd MMMM yyyy',
                                                    DateTime.now()),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(height: 20.0),
                                              GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    CustomPageRoute(
                                                        child: PresensiScreen(
                                                          latitude: _latitude,
                                                          longitude: _longitude,
                                                          username:
                                                              user['name'],
                                                          tenant_id:
                                                              user['tenant_id'],
                                                        ),
                                                        direction:
                                                            AxisDirection.left),
                                                  );
                                                },
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                  elevation: 0,
                                                  color:
                                                      const Color(0xFFE6ECF6),
                                                  child: SizedBox(
                                                    width: size.width / 3,
                                                    height: 40,
                                                    child: Center(
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: <
                                                              InlineSpan>[
                                                            WidgetSpan(
                                                              alignment:
                                                                  PlaceholderAlignment
                                                                      .middle,
                                                              child: Icon(
                                                                Icons
                                                                    .qr_code_rounded,
                                                                color: Color(
                                                                    0XFFFA4A0C),
                                                                size: 13,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: ' Check-in',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16),
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
                                    )
                                  ],
                                ))),
                        // End Card Absensi

                        //Card Check list Atm
                        CardContainer(
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.checklist,
                                        color: Color(0XFFFA4A0C),
                                        size: 35,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: size.width / 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Checklist Overview',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      ),
                                      SizedBox(height: 20.0),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ChecklistIsCheckedScreen()),
                                              );
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              elevation: 0,
                                              color: const Color(0xFFE6ECF6),
                                              child: SizedBox(
                                                width: size.width / 3.5,
                                                height: 40,
                                                child: Center(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                            text:
                                                                ' $totalIsChecked' +
                                                                    " Sudah",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _onItemTapped(1);
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              elevation: 0,
                                              color: Color(0xFFE6ECF6),
                                              child: SizedBox(
                                                width: size.width / 3.5,
                                                height: 40,
                                                child: Center(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                            text:
                                                                ' $totalIsNotChecked' +
                                                                    " Belum",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        //  End Card Check list arm

                        //  Card Lapor Temuan
                        CardContainer(
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.request_page_outlined,
                                        color: Color(0XFFFA4A0C),
                                        size: 35,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: size.width / 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Request Order',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 20.0),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RequestOrderScreen(),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              elevation: 0,
                                              color: Color(0xFFE6ECF6),
                                              child: SizedBox(
                                                width: size.width / 3.5,
                                                height: 40,
                                                child: Center(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                            text:
                                                                '$totalRequestOrder' +
                                                                    " Request",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RequestOrderScreen(),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                              elevation: 0,
                                              color: Color(0xFFE6ECF6),
                                              child: SizedBox(
                                                width: size.width / 3.5,
                                                height: 40,
                                                child: Center(
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        TextSpan(
                                                            text:
                                                                '$totalApprovedRequestOrder' +
                                                                    " Approved",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        //  End Card Lapor Temuan
                      ],
                    ),
            ],
          )),
    );
  }
}
