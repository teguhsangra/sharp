import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:telkom/config/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:telkom/ui/auth/edit_profile/edit_profile.dart';
import 'package:telkom/ui/auth/change_password/change_password.dart';
import 'package:telkom/ui/dashboard/dashboard_screen.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:unicons/unicons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';

  var imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user').toString());

    if (user != null) {
      setState(() {
        username = user['name'];
        email = user['email'];
      });
    }
  }

  Future<void> _handleSignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));

    preferences.clear();
  }

  void deleteAccount() async {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.loading,
    );
    var data = {"email": email};
    var res = await Network().postUrl('delete_user', data);
    var body = json.decode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoginScreen();
      }));

      preferences.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pengaturan Akun',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditProfile()),
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(UniconsLine.user_circle,
                                  size: kSpacingUnit.w * 2.5,
                                  color: Colors.black),
                              SizedBox(width: kSpacingUnit.w * 1.5),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              Spacer(),
                              Icon(
                                UniconsLine.angle_right,
                                size: kSpacingUnit.w * 2.5,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChangePassword()),
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(UniconsLine.lock_access,
                                  size: kSpacingUnit.w * 2.5,
                                  color: Colors.black),
                              SizedBox(width: kSpacingUnit.w * 1.5),
                              Text(
                                'Ubah Password',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              Spacer(),
                              Icon(
                                UniconsLine.angle_right,
                                size: kSpacingUnit.w * 2.5,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        GestureDetector(
                          onTap: () {
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.confirm,
                                title: 'Hapus Akun',
                                text:
                                    "Menghapus akun ini akan menghapus data akun tersebut dari ponsel!",
                                onConfirmBtnTap: () {
                                  deleteAccount();
                                });
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(UniconsLine.user_times,
                                  size: kSpacingUnit.w * 2.5,
                                  color: Colors.black),
                              SizedBox(width: kSpacingUnit.w * 1.5),
                              Text(
                                'Hapus Akun',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              Spacer(),
                              Icon(
                                UniconsLine.angle_right,
                                size: kSpacingUnit.w * 2.5,
                              ),
                            ],
                          ),
                        )
                      ],
                    ))),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        elevation: 0,
        child: GestureDetector(
          onTap: () {
            _handleSignOut();
          },
          child: Container(
            height: 60,
            margin: EdgeInsets.symmetric(
                    horizontal: kSpacingUnit.w * 2, vertical: 20)
                .copyWith(
              bottom: kSpacingUnit.w * 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: kSpacingUnit.w * 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.red,
            ),
            child: Row(
              children: <Widget>[
                Icon(UniconsLine.sign_out_alt,
                    size: kSpacingUnit.w * 2.5, color: Colors.white),
                SizedBox(width: kSpacingUnit.w * 1.5),
                Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
