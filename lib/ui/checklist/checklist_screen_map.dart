import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:telkom/model/checklist_result.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/checklist/checklist_detail_screen.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:map_launcher/map_launcher.dart' as ml;

class ChecklistMapScreen extends StatefulWidget {
  const ChecklistMapScreen({super.key});

  @override
  State<StatefulWidget> createState() => ChecklistMapState();
}

class ChecklistMapState extends State<ChecklistMapScreen> {
  bool isLoading = true;
  List checklistResults = [];
  final List<Marker> locations = <Marker>[];

  Completer<GoogleMapController> _controller = Completer();
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getChecklistResult();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getChecklistResult() async {
    var res = await Network()
        .getData('checklist_results-per-locations?check_unfinish=Y');

    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        resultData['data'].forEach((v) {
          checklistResults.add(v);
        });
      });
      setLocationMarker();
    }
  }

  void setLocationMarker() async {
    var location_id = null;

    setState(() {
      for (var checklist in checklistResults) {
        locations.add(Marker(
          markerId: MarkerId('${checklist['name']}'),
          position: LatLng(checklist['latitude'], checklist['longitude']),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () async {
            var google = await ml.MapLauncher.isMapAvailable(ml.MapType.google);

            if (google == true) {
              ml.MapLauncher.showMarker(
                mapType: ml.MapType.google,
                coords:
                    ml.Coords(checklist['latitude'], checklist['longitude']),
                title: '${checklist['name']}',
                description: '${checklist['name']}',
              );
            }
          },
        ));
      }
    });

    // print(locations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE50404),
        title: Text("Checklist Map"),
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
      ),
      body: isLoading
          ? Column(
              children: [
                CardPageSkeleton(
                  totalLines: 5,
                ),
                CardPageSkeleton(
                  totalLines: 5,
                ),
              ],
            )
          : Stack(
              children: [
                GoogleMap(
                  liteModeEnabled: false,
                  mapType: MapType.normal,
                  onTap: (position) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  onCameraMove: (position) {
                    _customInfoWindowController.onCameraMove!();
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _customInfoWindowController.googleMapController =
                        controller;
                  },
                  markers: locations.toSet(),
                  initialCameraPosition: CameraPosition(
                      target: LatLng(-7.0133575, 107.7484459), zoom: 12),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 200,
                  width: 300,
                  offset: 35,
                ),
              ],
            ),
    );
  }
}
