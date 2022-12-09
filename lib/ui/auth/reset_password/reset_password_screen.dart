import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/login/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  String email;


  ResetPasswordScreen({
    Key? key,
    this.email = '',
  }) : super(key: key);


  @override
  State<StatefulWidget> createState() => ResetPasswordState(email);
}

class ResetPasswordState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isPassword = true;
  bool securePassword = true;
  var tenantId;
  var email;
  var password;
  var passwordConfirmation;
  ResetPasswordState(this.email);

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
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation
    };
    showAlertDialog(context);
    if (_formKey.currentState!.validate()) {
      try {
        var res = await Network().postResetPassword('reset_password', data);
        var body = json.decode(res.body);

        if(res.statusCode == 200 || res.statusCode == 201)
        {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: const Text('Sukses Update Password'),
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
                return LoginScreen();
              }),
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Error Gagal update password'),
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
                "Reset Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
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
                          Expanded(
                              child: TextFormField(
                                enabled: false,
                                initialValue: email,
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
                              )
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
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
                          Expanded(
                              child: TextFormField(
                                obscureText: securePassword,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value){
                                  setState(() {
                                    password = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                    suffixIcon: Visibility(
                                      visible: isPassword,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            securePassword = !securePassword;
                                          });
                                        },
                                        child: Icon(
                                          securePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    )
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Masukkan password dengan benar";
                                  }else{
                                    if (value.length < 8) {
                                      return 'minimal 8 karakter';
                                    } else {
                                      return null;
                                    }
                                  }
                                },
                              )
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
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
                          Expanded(
                              child: TextFormField(
                                obscureText: securePassword,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value){
                                  setState(() {
                                    passwordConfirmation = value;
                                  });
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Password Confirmation",
                                    suffixIcon: Visibility(
                                      visible: isPassword,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            securePassword = !securePassword;
                                          });
                                        },
                                        child: Icon(
                                          securePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    )
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Masukkan password dengan benar";
                                  }else{
                                    if (value.length < 8) {
                                      return 'minimal 8 karakter';
                                    }else if(value != password){
                                      return 'password not match';
                                    }else{
                                      return null;
                                    }
                                  }
                                },
                              )
                          )
                        ],
                      ),
                    )
                  ],
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
                        primary: Color(0xFFFA4A0C),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      submit();
                    },
                    child: Text("Submit Reset Password")),
              ),

            ],
          ),
        ),
      ),
    );
  }
}