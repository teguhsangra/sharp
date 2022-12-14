import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telkom/network/api.dart';
import 'package:pinput/pinput.dart';
import 'package:telkom/ui/auth/reset_password/reset_password_screen.dart';

class OTPScreen extends StatefulWidget {
  String email;


  OTPScreen({
    Key? key,
    this.email = '',
  }) : super(key: key);


  @override
  State<StatefulWidget> createState() =>OTPState(email);
}

class OTPState extends State<OTPScreen> {

  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  var tenantId;
  var email;
  var code;
  OTPState(this.email);

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
                  "Sedang memuat...",
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

  void initState() {
    super.initState();
    getTenant();
  }

  void getTenant() async {
    var tenantData = await Network().getTenant('get_tenant?code=BIRAWAATM');

    if (tenantData != null) {
      setState(() {
        tenantId = tenantData.data.id;
      });
    }
  }

  void submit() async{
    FocusScope.of(context).unfocus();
    var data = {
      "tenant_id":tenantId,
      "code": code,
    };
    if(code == null)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text('Kode OTP Harus Diisi'),
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
    }else{
      showAlertDialog(context);
      try {
        var res = await Network().postRequestOTP('verify_otp', data);
        var body = json.decode(res.body);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Sukses Verify OTP'),
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) {
              return ResetPasswordScreen(email: email,);
            }),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Error Kode OTP Salah'),
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
      }
    }

  }

  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/img1.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "OTP Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                // defaultPinTheme: defaultPinTheme,
                // focusedPinTheme: focusedPinTheme,
                // submittedPinTheme: submittedPinTheme,

                showCursor: true,
                onCompleted: (pin){
                  setState(() {
                      code = pin;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFFE50404),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      submit();
                    },
                    child: Text("Verify OTP")),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Edit Email Address ?",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}