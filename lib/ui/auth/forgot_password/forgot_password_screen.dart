import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/otp_screen/otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordState();
}
class ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  var tenantId;
  var email;

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
    if (_formKey.currentState!.validate()) {

        var data = {
          "tenant_id":tenantId,
          "email": email,
        };
        showAlertDialog(context);
        try {

          var res = await Network().postRequestOTP('request_otp', data);
          var body = json.decode(res.body);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: const Text('Sukses Reqeust OTP, check email anda'),
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
                return OTPScreen(email: email,);
              }),
            ),
          );
        } catch (e) {

        }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Request OTP",
          style: TextStyle(color: Colors.black),
        ),

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
                "Email Verification",
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
              Form(
                key: _formKey,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 40,
                        child: Icon(Icons.mail),
                      ),
                      Text(
                        "|",
                        style: TextStyle(fontSize: 33, color: Colors.grey),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value){
                              setState(() {
                                email = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Masukkan email yang benar";
                              }
                              return null;
                            },
                          ))
                    ],
                  ),
                ),
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
                    child: Text("Send the OTP Code")),
              )
            ],
          ),
        ),
      ),
    );
  }

}