import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:telkom/components/card.dart';



import 'package:telkom/network/api.dart';
import 'package:telkom/constants.dart';
import 'package:telkom/components/CustomPageRoute.dart';
import 'package:telkom/ui/stock/stock_screen.dart';

import '../../components/helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loader_skeleton/loader_skeleton.dart';

import 'package:telkom/ui/home/presensi_screen.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:telkom/ui/auth/profile/profile_screen.dart';
import 'package:telkom/ui/checklist/checklist_screen.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/checklist/checklist_is_checked_screen.dart';
import 'package:telkom/ui/sales_order/sales_order_screen.dart';


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
      locationName = '${place.street},${place.locality}';
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

  Future checkInDialog() async {
    var checkIn = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new PresensiScreen();
        }));

    if (checkIn != null) {
      setState(() {
        checkin = true;
      });
      checkUnsignout();
    }
  }

  Future checkOutDialog() async {
    var checkOut = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new PresensiScreen(
              unSignout: unSignout
          );
        }));
    if (checkOut != null) {
      setState(() {
        checkin = false;
      });
      checkUnsignout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: index,
        children: [
          HomeIndex(context),
          const SalesOrderScreen(),
          const StockScreen(),
          const ProfileScreen()
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: GNav(
            color: const Color(0xFFE50404),
            activeColor: const Color(0xFFE50404),
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
              GButton(icon: Icons.request_page_outlined, text: 'Sales Order'),
              GButton(icon: Icons.check_circle, text: 'Stock'),
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
                height: 220,
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
                                        new IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white,), onPressed: () {
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
                                              counter >= 9 ? '9 +' : '$counter',
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
                                  color: Color(0xFF2109B4),
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
                        Column(
                          children: [
                            (checkin
                                ?
                            CardCheckOut()
                                :
                            CardCheckin()
                            )
                          ],
                        ),
                        // End Card Absensi
                        CardContainer(
                            height: 140,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              14),
                                        ),
                                        elevation: 0,
                                        color:
                                        const Color(0xFFE6ECF6),
                                        child: Container(
                                          width: 140,
                                          height: 100,
                                          padding: EdgeInsets.all(15),
                                          child: Column(
                                            children: [
                                              Align(
                                                child: Text(
                                                  'Pencapaian',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        '55',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.red
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text(
                                                          'Unit Terjual',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.black54
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 20,),
                                                  Column(
                                                    children: [
                                                      Text(
                                                          '101',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                              color: Colors.blue
                                                          )
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text(
                                                          'Point',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.black54
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              14),
                                        ),
                                        elevation: 0,
                                        color:
                                        const Color(0xFFE6ECF6),
                                        child: Container(
                                          width: 140,
                                          height: 100,
                                          padding: EdgeInsets.all(15),
                                          child: Column(
                                            children: [
                                              Align(
                                                child: Text(
                                                  'Target',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        '55',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.red
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text(
                                                          'Unit Terjual',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.black54
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 20,),
                                                  Column(
                                                    children: [
                                                      Text(
                                                          '100',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                              color: Colors.blue
                                                          )
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text(
                                                          'Point',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.black54
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                        ),
                        SizedBox(height: 10,),
                        CardMenu()
                      ],
                    ),
            ],
          )),
    );
  }


  Widget CardCheckin(){
    Size size = MediaQuery.of(context).size;
    return  Container(
      width: size.width,
      height: 150,
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
          color:  Color(0xFFE50404),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 2,
                // Shadow position
                spreadRadius: 3,
                offset: const Offset(0, 3)),
          ]),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal:10, vertical: 10),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Masuk untuk absen", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                Icon(
                  Icons.access_alarm,
                  color: Colors.white,
                  size: 35,
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDate('dd MMMM yyyy',
                      DateTime.now()),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
                GestureDetector(
                  onTap: () async {
                    checkInDialog();
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
                                      .qr_code_rounded,
                                  color: Colors.blue,
                                  size: 14,
                                ),
                              ),
                              TextSpan(
                                text: ' Check-in',
                                style: TextStyle(
                                    color: Colors
                                        .black,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget CardCheckOut(){
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 190,
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
          color:  Color(0xFFE50404),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 2,
                // Shadow position
                spreadRadius: 3,
                offset: const Offset(0, 3)),
          ]),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal:10, vertical: 10),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Presensi", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                Text(
                  formatDate('dd MMMM yyyy',
                      DateTime.now()),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal:10, vertical: 10),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.white,
                      size: 14,
                    ),
                    Container(
                      child: Text(
                        maxLines:4,
                        softWrap: true,
                        ' $locationName',
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                GestureDetector(
                  onTap: () async {
                    checkOutDialog();
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
            ),
          )
        ],
      ),
    );
  }

  Widget CardMenu(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 1,
                // Shadow position
                spreadRadius: 1,
                offset: const Offset(0, 2)),
          ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sell,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'Penjualan',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'Stok Barang',

                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dataset,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'Data Barang',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_chart_outlined_outlined,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height: 5,),
                    Text(
                      'Report',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.supervisor_account_rounded,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height: 5,),
                    Text(
                      'Competitor Info',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.supervisor_account_rounded,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height:5,),
                    Text(
                      'Competitor \n Activity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.feedback,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(height: 5,),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}
