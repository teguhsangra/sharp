import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/rounded_input_field.dart';
import 'package:telkom/components/rounded_password_field.dart';
import 'package:telkom/ui/auth/forgot_password/forgot_password_screen.dart';
import 'package:telkom/ui/home/home_screen.dart';
import 'package:telkom/network/api.dart';
import '../../../../constants.dart';
import 'dart:io' show Platform;

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<LoginForm> {
  get validate => null;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Change here
    _firebaseMessaging.getToken().then((token){
      print(token);
      setState(() {
        tokenFCM = token;
      });
    });
    getTenant();
  }

  void getTenant() async {
    var tenantData = await Network().getTenant('get_tenant?code=BIRAWASFA');

    if (tenantData != null) {
      setState(() {
        tenantId = tenantData.data.id;
      });
    }
  }



  final _formKey = GlobalKey<FormState>();

  String? email;
  String? password;
  int? tenantId;
  var tokenFCM;



  bool? isLoading = false;
  bool secureText = true;

  showHide() {
    setState(() {
      secureText = !secureText;
    });
  }

  showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void login() async {
    var platform;
    FocusScope.of(context).unfocus();
    if(Platform.isAndroid){
      platform = 'android';
    }else{
      platform = 'ios';
    }
    var data = {
      "email": email,
      "password": password,
      "tenant_id": tenantId,
      "device_token" : tokenFCM,
      "platform" : platform
    };
    if (_formKey.currentState!.validate()) {
      var res = await Network().auth(data, 'login');

      var body = json.decode(res.body);
      if (res.statusCode == 200) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString(
            'token', json.encode(body['data']['access_token']));
        localStorage.setString('user', json.encode(body['data']['user']));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Periksa email dan password anda',
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
            )
        );

      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Periksa email dan password anda',
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
          )
      );


    }

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.08,
          ),
          const Text(
            "Masuk",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          RoundedInputField(
            title: 'Email',
            hintText: "Email",
            enabled: true,
            maxlines: 1,
            icon: null,
            onChanged: (value) {
              // print(value);
              setState(() {
                email = value;
              });
            },
            initVal: '',
            validation: (value) {
              if (value.isEmpty) {
                return "Please enter your email";
              } else {
                return null;
              }
            },
            isNumber: false,
          ),
          RoundedPasswordField(
            title: 'Password',
            hintText: "Password",
            enabled: true,
            maxlines: 1,
            icon: null,
            password: true,
            onChanged: (passwordValue) {
              // print(value);
              setState(() {
                password = passwordValue;
              });
            },
            initVal: '',
            validation: (value) {
              if (value.isEmpty) {
                return 'Please enter your password';
              }else{
                return null;
              }

            },
            isNumber: false,
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) {
                        return ForgotPasswordScreen();
                      }),
                    ),
                  );

                },
                child: const Text(
                  "Lupa Password",
                  style: TextStyle(
                    color: kPrimaryColor,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 50,
            width: size.width * 0.8,
            decoration: BoxDecoration(
                color: kPrimaryColor, borderRadius: BorderRadius.circular(20)),
            child: TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  login();
                }
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),


        ],
      ),
    );
  }


}
