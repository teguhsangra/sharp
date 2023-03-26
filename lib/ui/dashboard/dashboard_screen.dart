import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:telkom/components/card.dart';
import 'package:telkom/components/dialog_pop_up_success_check_in.dart';
import 'package:telkom/components/dialog_pop_up_success_check_out.dart';

import 'package:telkom/network/api.dart';
import 'package:telkom/config/constants.dart';
import 'package:telkom/components/CustomPageRoute.dart';
import 'package:telkom/ui/asset/asset_screen.dart';
import 'package:telkom/ui/competitor/compotior_activity_screen.dart';
import 'package:telkom/ui/competitor/compotior_info_screen.dart';
import 'package:telkom/ui/feedback/feedback_screen.dart';
import 'package:telkom/ui/home/home_screen.dart';
import 'package:telkom/ui/point/point_screen.dart';
import 'package:telkom/ui/report/report_screen.dart';
import 'package:telkom/ui/stock/stock_screen.dart';

import '../../components/helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:unicons/unicons.dart';

import 'package:telkom/ui/dashboard/presensi_screen.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:telkom/ui/auth/profile/profile_screen.dart';
import 'package:telkom/ui/checklist/checklist_screen.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/checklist/checklist_is_checked_screen.dart';
import 'package:telkom/ui/sales_order/sales_order_screen.dart';

class DashboardScreen extends StatefulWidget {
  bool checkin;
  int selectedTab;

  DashboardScreen({
    Key? key,
    this.selectedTab = 0,
    this.checkin = false,
  }) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState(checkin, selectedTab);
}

class DashboardScreenState extends State<DashboardScreen> {
  late LocationSettings locationSettings;

  bool checkin = false;
  int index = 0;

  DashboardScreenState(this.checkin, this.index);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: index,
        children: [
          HomeScreen(context),
          const SalesOrderScreen(),
          const StockScreen()
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 2,
                  // Shadow position
                  spreadRadius: 3,
                  offset: const Offset(0, 3)),
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
              color: const Color(0xFFE50404),
              activeColor: const Color(0xFFffffff),
              gap: 8,
              tabBackgroundColor: const Color(0xFFE50404),
              padding: const EdgeInsets.all(15),
              iconSize: 20,
              selectedIndex: index,
              onTabChange: (int selectedIndex) {
                setState(() {
                  index = selectedIndex;
                });
              },
              tabs: const [
                GButton(icon: UniconsLine.estate, text: 'Home'),
                GButton(icon: UniconsLine.tag, text: 'Sales Order'),
                GButton(icon: UniconsLine.clipboard, text: 'Stock'),
              ]),
        ),
      ),
    );
  }
}
