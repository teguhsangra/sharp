import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telkom/config/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:telkom/model/password.dart';
import 'package:telkom/network/api.dart';
import 'package:unicons/unicons.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  bool _passwordVisible3 = false;

  final formKey = GlobalKey<FormState>();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    _passwordVisible1 = false;
    _passwordVisible2 = false;
    _passwordVisible3 = false;
    _getDataUser();
  }

  int tenant_id = 0;
  String email = '';
  String new_password = '';
  String new_password_confirmation = '';

  TextEditingController _new_password = TextEditingController();
  TextEditingController _new_password_confirmation = TextEditingController();

  _getDataUser() async {
    try {
      final res = await Network().getData('me');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          email = data['data']['user']['person']['email'];
          tenant_id = data['data']['user']['person']['tenant_id'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _save() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        tenant_id = tenant_id;
        email = email;
        new_password = _new_password.text;
        new_password_confirmation = _new_password_confirmation.text;
      });
      try {
        Password pass = Password(tenant_id, email, "zakiezakie", new_password,
            new_password_confirmation);
        final res =
            await Network().updatePassword('update_password/', pass.toJson());
        print("res statusCode: " + res.statusCode.toString());
        print(pass.toJson());
        print(jsonDecode(res.body));
        if (res.statusCode == 200) {
          print("success save");
          print(jsonDecode(res.body));

          showInSnackBar("Berhasil update password", Colors.green);
        }
      } catch (e) {
        print("error di try save:$e");

        showInSnackBar(e.toString(), Colors.red);
      }
    } else {
      print("terkena validasi");

      showInSnackBar("Gagal update password", Colors.red);
    }
  }

  showInSnackBar(String value, Color color) {
    _messangerKey.currentState!.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(value),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Ubah password",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => {Navigator.pop(context, true)},
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: kSpacingUnit.w * 2),
          Expanded(
              child: Form(
                key: formKey,
                child: ListView(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:20,vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password Baru',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: kSpacingUnit.w * 5.5,
                    margin: EdgeInsets.symmetric(
                      horizontal: kSpacingUnit.w * 2,
                    ).copyWith(
                      bottom: kSpacingUnit.w * 2,
                    ),
                    child: TextFormField(
                      obscureText: !_passwordVisible2,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide()),
                        labelText: '',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible2
                                ? UniconsLine.eye
                                : UniconsLine.eye_slash,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible2 = !_passwordVisible2;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password baru wajib diisi";
                        } else {
                          if (value.length < 8) {
                            return 'minimal 8 karakter';
                          } else {
                            return null;
                          }
                        }
                      },
                      controller: _new_password,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:20,vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Konfirmasi Password Baru',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: kSpacingUnit.w * 5.5,
                    margin: EdgeInsets.symmetric(
                      horizontal: kSpacingUnit.w * 2,
                    ).copyWith(
                      bottom: kSpacingUnit.w * 2,
                    ),
                    child: TextFormField(
                      obscureText: !_passwordVisible3,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide()),
                        labelText: '',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible3
                                ? UniconsLine.eye
                                : UniconsLine.eye_slash,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible3 = !_passwordVisible3;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Konfirmasi password wajib diisi";
                        } else {
                          if (value != _new_password.text) {
                            return "Konfirmasi password tidak sama";
                          } else {
                            return null;
                          }
                        }
                      },
                      controller: _new_password_confirmation,
                    ),
                  )
                ]),
              ))
        ],
      ),
        bottomNavigationBar: Container(
          height: 100,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                height: 50,
                width: size.width,
                decoration: BoxDecoration(
                    color: Color(0xFF000075),
                    borderRadius: BorderRadius.circular(18)),
                child: TextButton(
                  onPressed: () {
                    _save();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
