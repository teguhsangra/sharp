import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:telkom/components/CustomPageRoute.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:telkom/network/api.dart';
import 'package:telkom/constants.dart';
import 'package:telkom/ui/home/home_screen.dart';
import '../../components/helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PresensiScreen extends StatefulWidget {
  Map unSignout;

  PresensiScreen(
      {
        Key? key,
        this.unSignout = const {}
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PresensiScreenState(unSignout);
}

class PresensiScreenState extends State<PresensiScreen> {
  PanelController _panelController = PanelController();
  static const double fabHeightClosed = 320;
  double fabHeight = fabHeightClosed;

  bool isOutArea = false;
  bool isLoading = true;
  bool _isMockLocation = false;

  var user = {};
  var unSignout = {};
  var image;
  double _latitude = 0;
  double _longitude = 0;
  String locationName = '';
  final List<Marker> locations = <Marker>[];

  PresensiScreenState(this.unSignout);


  void initState() {
    super.initState();
    loadUserData();
    _getLocationLatLong();
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
    getAddressFromLongLat(position);
    isLoading = false;
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    setState(() {
      locationName = '${place.street},${place.locality},${place.country}';
      locations.add(Marker(
        markerId: MarkerId("$locationName"),
        position: LatLng(_latitude, _longitude),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _getFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        preferredCameraDevice: CameraDevice.front);

    if (pickedFile == null) return;
    final imageTemp = File(pickedFile.path);
    setState(() => this.image = imageTemp);
  }

  void checkIn() async {
    DateTime dateTime = DateTime.now();
    // Get mime type
    final _image = await image?.readAsBytes();
    final mime = lookupMimeType('', headerBytes: _image);
    // convert to base64
    Uint8List? imagebytes = await image?.readAsBytes();
    String base64string = base64.encode(imagebytes!);

    var date = formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now());
    var data = {
      "tenant_id": user['tenant_id'],
      "employee_id": user['person']['employee']['id'],
      "sign_in_at": date,
      "sign_in_picture_path":
      "data:" + mime.toString() + ";base64," + base64string,
      "sign_in_latitude": _latitude,
      "sign_in_longitude": _longitude,
      "timezone": dateTime.timeZoneName,
    };
    if (isOutArea) {
      Navigator.pop(context);
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
    } else {

      var res = await Network().postCheckIn('presences', data);
      var body = json.decode(res.body);

      if (res.body != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Sukses Check-in'),
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
        Navigator
            .of(context)
            .pop(body['data']);
      }
    }
  }

  void checkOut() async {
    DateTime dateTime = DateTime.now();
    // Get mime type
    final _image = await image?.readAsBytes();
    final mime = lookupMimeType('', headerBytes: _image);
    // convert to base64
    Uint8List? imagebytes = await image?.readAsBytes();
    String base64string = base64.encode(imagebytes!);

    var date = formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now());
    var data = {
      "tenant_id": unSignout['tenant_id'],
      "employee_id": unSignout['employee_id'],
      "sign_in_at": unSignout['sign_in_at'],
      "sign_in_picture_path": unSignout['sign_in_picture_path'],
      "sign_in_latitude": unSignout['sign_in_latitude'],
      "sign_in_longitude": unSignout['sign_in_longitude'],
      "sign_out_at": date,
      "sign_out_picture_path":
      "data:" + mime.toString() + ";base64," + base64string,
      "sign_out_latitude": _latitude,
      "sign_out_longitude": _longitude,
      "timezone": dateTime.timeZoneName,
    };
    if (isOutArea) {
      Navigator.pop(context);
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
    } else {
      var res =
      await Network().postCheckOut('presences/${unSignout['id']}', data);
      var body = json.decode(res.body);

      if (res.body != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Sukses Check-out'),
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
        Navigator
            .of(context)
            .pop(body['data']);

      }
    }

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

    var ignore_latlong = employee['ignore_latlong'];
    if(ignore_latlong == 1)
    {
      for (var item in location) {
        totalDistance = calculateDistance(
            _latitude, _longitude, item['latitude'], item['longitude']);

        if (totalDistance * 1000 > toleranceDistance) {
          // outOfArea = true;
          // break;
        }
        outOfArea = false;
      }
    }
    setState(() {
      isOutArea = false;
    });
  }

  void togglePanel() => _panelController.isPanelOpen ? _panelController.close() : _panelController.open();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final panelHeightOpen = size.height * 0.8;
    final panelHeightClosed = size.height * 0.4;
    return Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Container(
          margin:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        )
            : Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              SlidingUpPanel(
                backdropEnabled:true,
                backdropColor: Colors.black12,
                parallaxEnabled: true,
                parallaxOffset: .5,
                controller: _panelController,
                isDraggable: true,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                maxHeight: panelHeightOpen,
                minHeight: panelHeightClosed,
                body: Container(
                  height: 200,
                  child:  GoogleMap(
                      markers: locations.map((e) => e).toSet(),
                      initialCameraPosition: CameraPosition(
                          target: LatLng(_latitude, _longitude), zoom: 20)),
                ),
                panelBuilder: (controller){
                  return Column(
                    children: [
                      SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                togglePanel();
                              },
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 15),
                                  height: 5,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(unSignout.length > 0 ? 'Check-Out' :'Check-In', style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),)
                                  ),
                                  SizedBox(height: 20,),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(unSignout.length > 0 ? 'Lokasi Check-Out' : 'Lokasi Check-In', style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),)
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:250,
                                        child: Text(
                                            locationName,
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors
                                                    .black,
                                                fontSize:
                                                16)
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(unSignout.length > 0 ? 'Waktu Check-Out' :'Waktu Check-In', style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),)
                                  ),
                                  SizedBox(height: 10,),
                                  SizedBox(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text.rich(
                                          TextSpan(
                                            children: <
                                                InlineSpan>[
                                              TextSpan(
                                                  text: formatDate(
                                                      ' HH:mm:ss',
                                                      DateTime
                                                          .now()),
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontSize:
                                                      16)),
                                            ],
                                          ),
                                        ),
                                      )),
                                  SizedBox(height: 20,),

                                  (
                                      image != null ?
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical: 10),
                                                  width: 120,
                                                  height: 120,
                                                  child: FullScreenWidget(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: Image.file(
                                                          image,
                                                          fit: BoxFit.cover
                                                      ),
                                                    ),
                                                  )
                                              ),
                                              Positioned(
                                                right: 5.0,
                                                child: InkWell(
                                                  child: Icon(
                                                    Icons.remove_circle,
                                                    size: 30,
                                                    color: Colors.red,
                                                  ),
                                                  // This is where the _image value sets to null on tap of the red circle icon
                                                  onTap: () {
                                                    setState(
                                                          () {
                                                        image = null;
                                                      },
                                                    );
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ) :
                                      Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal:
                                              50,
                                              vertical: 50),
                                          alignment:
                                          Alignment.center,
                                          child: Wrap(
                                            spacing: 10.0,
                                            runSpacing: 10.0,
                                            crossAxisAlignment:
                                            WrapCrossAlignment
                                                .center,
                                            alignment:
                                            WrapAlignment
                                                .center,
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () async {
                                                  final pickedFile = await ImagePicker().pickImage(
                                                      source: ImageSource
                                                          .camera,
                                                      maxWidth:
                                                      1800,
                                                      maxHeight:
                                                      1800,
                                                      preferredCameraDevice:
                                                      CameraDevice
                                                          .front);

                                                  if (pickedFile ==
                                                      null)
                                                    return;
                                                  final imageTemp =
                                                  File(pickedFile
                                                      .path);
                                                  setState(() =>
                                                  image =
                                                      imageTemp);

                                                },
                                                child: Card(
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        18.0),
                                                  ),
                                                  elevation: 0,
                                                  color: const Color(
                                                      0xFFE50404),
                                                  child:
                                                  const SizedBox(
                                                    width: 200,
                                                    height: 70,
                                                    child:
                                                    Center(
                                                      child: Text
                                                          .rich(
                                                        TextSpan(
                                                          children: <
                                                              InlineSpan>[
                                                            WidgetSpan(
                                                              alignment: PlaceholderAlignment.middle,
                                                              child: Icon(
                                                                Icons.face_unlock_outlined,
                                                                color: Colors.white,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                                text: ' Take a photo selfie',
                                                                style: TextStyle(color: Colors.white, fontSize: 18)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )

                                      )
                                  ),
                                ],
                              ),

                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
                onPanelSlide: (position){
                  setState(() {
                    final panelMaxScrollExtent = panelHeightOpen - panelHeightClosed;

                    fabHeight = position * panelMaxScrollExtent + fabHeightClosed;
                  });
                },
                footer:Container(
                  color: Colors.white,
                  width: size.width,
                  padding: EdgeInsets.all(20),
                  child:
                  GestureDetector(
                    onTap: () async {
                      if(unSignout.length > 0){
                        checkOut();
                      }else{
                        checkIn();
                      }
                    },
                    child: Card(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            18.0),
                      ),
                      elevation: 0,
                      color: image == null
                          ? Color(
                          0xFFD7D4D3)
                          : Color(
                          0xFFE50404),
                      child:
                      SizedBox(
                        width: 200,
                        height: 70,
                        child: Center(
                          child:
                          Text.rich(
                            TextSpan(
                              children: <
                                  InlineSpan>[
                                WidgetSpan(
                                  alignment:
                                  PlaceholderAlignment.middle,
                                  child:
                                  Icon(
                                    unSignout.length > 0 ? Icons.logout  :Icons
                                        .directions_walk,
                                    color:
                                    Colors.white,
                                    size:
                                    20,
                                  ),
                                ),
                                TextSpan(
                                    text: unSignout.length > 0 ? ' Check-Out' :' Check-In',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: 10,
                  bottom: fabHeight,
                  child: FloatingActionButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                        size: 30,
                      )
                  )
              )
            ]
        )
    );
  }
}