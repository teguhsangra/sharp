import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';
import 'package:telkom/ui/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    checkLoggedin();

  }
  void checkLoggedin() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var token = localStorage.getString('token');

    if (token != null) {
      setState(() {
        isStarted = true;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    }else{
      setState(() {
        isStarted = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top:60,
            left:20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BIRAWA',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color(0xFF818088)
                ),),Text('SHARP',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Color(0xFFE50404)
                ),)

              ],
            ),
          ),
          Positioned(
            top:140,
            left:30,
            right:30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aplikasi untuk mempermudah petugas dalam melakukan pekerjaan, memonitoring dan record selling',style: TextStyle(
                    fontSize: 12
                ),)

              ],
            ),
          ),
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/logo_spalsh.png",
              fit: BoxFit.fill,
            ),
          ),
          if(isStarted == false)
          Positioned(
              bottom: 50,
              left: 60,
              right: 60,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 50,
                decoration: BoxDecoration(
                    color: Color(0xFFE50404), borderRadius: BorderRadius.circular(30)),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: const Text(
                    'Mulai',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
