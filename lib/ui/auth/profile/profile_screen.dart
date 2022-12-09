import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:telkom/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:telkom/ui/auth/edit_profile/edit_profile.dart';
import 'package:telkom/ui/auth/change_password/change_password.dart';
import 'package:telkom/ui/home/home_screen.dart';
import 'package:cool_alert/cool_alert.dart';

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

  void deleteAccount() async{
    CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
    );
    var data = {
      "email":email
    };
    var res = await Network().postUrl('delete_user', data);
    var body = json.decode(res.body);
    if(res.statusCode == 200 || res.statusCode == 201)
    {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: kSpacingUnit.w * 5.5),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/hero_profile.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${username}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${email}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Container(
                height: kSpacingUnit.w * 5.5,
                margin: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ).copyWith(
                  bottom: 15,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ),
                decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Color(0xFFF2F2F2),),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 2,
                            // Shadow position
                            spreadRadius: 1,
                            offset: const Offset(0, 3)),
                      ]),
                      child: Icon(Icons.home,
                          size: kSpacingUnit.w * 2.5, color: kSecondaryColor),
                    ),
                    SizedBox(width: kSpacingUnit.w * 1.5),
                    Text(
                      'Home',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: kSpacingUnit.w * 2.5,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfile()),
                );
              },
              child: Container(
                height: kSpacingUnit.w * 5.5,
                margin: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ).copyWith(
                  bottom: 15,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color(0xFFF2F2F2),),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 2,
                                // Shadow position
                                spreadRadius: 1,
                                offset: const Offset(0, 3)),
                          ]),
                      child: Icon(Icons.account_circle,
                          size: kSpacingUnit.w * 2.5, color: kSecondaryColor),
                    ),
                    SizedBox(width: kSpacingUnit.w * 1.5),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: kSpacingUnit.w * 2.5,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePassword()),
                );
              },
              child: Container(
                height: kSpacingUnit.w * 5.5,
                margin: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ).copyWith(
                  bottom: 15,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color(0xFFF2F2F2),),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 2,
                                // Shadow position
                                spreadRadius: 1,
                                offset: const Offset(0, 3)),
                          ]),
                      child: Icon(Icons.key,
                          size: kSpacingUnit.w * 2.5, color: kSecondaryColor),
                    ),
                    SizedBox(width: kSpacingUnit.w * 1.5),
                    Text(
                      'Ubah Password',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: kSpacingUnit.w * 2.5,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: kSpacingUnit.w * 5.5,
              margin: EdgeInsets.symmetric(
                horizontal: kSpacingUnit.w * 2,
              ).copyWith(
                bottom: 15,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: kSpacingUnit.w * 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Color(0xFFF2F2F2),),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 2,
                              // Shadow position
                              spreadRadius: 1,
                              offset: const Offset(0, 3)),
                        ]),
                    child: Icon(Icons.info,
                        size: kSpacingUnit.w * 2.5, color: kSecondaryColor),
                  ),
                  SizedBox(width: kSpacingUnit.w * 1.5),
                  Text(
                    'Faq',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: kSpacingUnit.w * 2.5,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.confirm,
                    title: 'Hapus Akun',
                    text: "Menghapus akun ini akan menghapus data akun tersebut dari ponsel!",
                    onConfirmBtnTap: (){
                      deleteAccount();
                    }
                );
              },
              child: Container(
                height: kSpacingUnit.w * 5.5,
                margin: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ).copyWith(
                  bottom: 15,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color(0xFFF2F2F2),),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 2,
                                // Shadow position
                                spreadRadius: 1,
                                offset: const Offset(0, 3)),
                          ]),
                      child: Icon(Icons.remove_circle,
                          size: kSpacingUnit.w * 2.5, color: kSecondaryColor),
                    ),
                    SizedBox(width: kSpacingUnit.w * 1.5),
                    Text(
                      'Hapus Akun',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: kSpacingUnit.w * 2.5,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50,),
            GestureDetector(
              onTap: () {
                _handleSignOut();
              },
              child: Container(
                height: kSpacingUnit.w * 5.5,
                margin: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ).copyWith(
                  bottom: kSpacingUnit.w * 2,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: kSpacingUnit.w * 2,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
                    color: Colors.red,),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.logout,
                        size: kSpacingUnit.w * 2.5, color: Colors.white),
                    SizedBox(width: kSpacingUnit.w * 1.5),
                    Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
