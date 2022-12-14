import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:telkom/model/profile.dart';
import 'package:telkom/network/api.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  final List<String?> errors = [];

  bool operator ==(dynamic other) =>
      other != null && other;

  @override
  int get hashCode => super.hashCode;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _getDataUser();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

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

  String username = '';
  String email = '';

  int id = 0;
  int tenant_id = 0;
  String code = '';

  String nama = '';
  String no_hp = '';
  String kota = '';
  String negara = '';
  String type_identitas = "id_cards";
  String nomor_identitas = '';
  String alamat = '';



  var imageFile;

  var items = [
    {
      "name": "ID Card",
      "value": "id_cards"
    },
    {
      "name": "Driving License",
      "value": "driving_license"
    },
    {
      "name": "Passport",
      "value": "passport"
    }
  ];
  _getDataUser() async {
    try {
      final res = await Network().getData('me');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          username = data['data']['user']['person']['name'];
          email = data['data']['user']['person']['email'];

          id = data['data']['user']['person']['employee']['id'];
          tenant_id = data['data']['user']['person']['tenant_id'];
          code = data['data']['user']['person']['employee']['code'];

          nama = username;
          no_hp = data['data']['user']['person']['phone'];
          kota = data['data']['user']['person']['city'];
          negara = data['data']['user']['person']['country'];
          type_identitas = data['data']['user']['person']['identity_type'];
          nomor_identitas = data['data']['user']['person']['identity_number'];
          alamat = data['data']['user']['person']['address'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _save() async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
        var data = {
          "id": id,
          "tenant_id":tenant_id,
          "code": code,
          "email": email,
          "name": nama,
          "phone":no_hp,
          "city": kota,
          "country":negara,
          "identity_type":type_identitas,
          "identity_number": nomor_identitas,
          "address":alamat
        };

        showAlertDialog(context);
        try {
          var res = await Network().updateProfile('update_profile', data);
          var body = json.decode(res.body);

          if (res.statusCode == 201 || res.statusCode == 200) {
            Navigator.pop(context);

            SharedPreferences localStorage = await SharedPreferences.getInstance();
            localStorage.clear();
            localStorage.setString(
                'token', json.encode(body['data']['access_token']));
            localStorage.setString('user', json.encode(body['data']['user']));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: const Text('Sukses edit profile'),
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
        } catch (e) {
          showInSnackBar(e.toString(), Colors.red);
        }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text('Gagal edit profile'),
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

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
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
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _save(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Save",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE50404)
                    ),
                    )
                  ],
                ),
              ))
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => {Navigator.pop(context, true)},
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Form(
                  key: formKey,
                  child: Column(
                children: [
                  TextFormField(
                    initialValue: nama,
                    onChanged: (value) {
                      setState(() {
                        nama = value!;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty ||
                          !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                        addError(error: 'Masukkan nama yang benar');
                        return "Masukkan nama yang bena";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Nama",
                      hintText: "Masukan nama anda",
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: no_hp,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        code = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        addError(error: 'Masukkan nomor hp yang benar');
                        return "Masukkan nomor hp yang benar";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Nomor Handphone",
                      hintText: "Masukan Nomor HandphoneS",
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: kota,
                    onChanged: (value) {
                      setState(() {
                        kota = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        addError(error: 'Masukkan kota yang benar');
                        return "Masukkan kota yang benar";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Kota",
                      hintText: "Masukan Kota anda",
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.location_pin),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: negara,
                    onChanged: (value) {
                      setState(() {
                        negara = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        addError(error: 'Masukkan negara yang benar');
                        return "Masukkan negara yang benar";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Negara",
                      hintText: "Masukan Negara anda",
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      //
                    ),
                  ),
                  SizedBox(height: 20,),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Tipe Identitas'),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding:  EdgeInsets.all(5),
                    child: Container(
                      width: 400,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color:Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(19)
                      ),
                      child: DropdownButtonFormField(

                          value: type_identitas,
                          onChanged: (value) {
                            setState(() {
                              type_identitas = value.toString();
                            });
                          },
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                          items: items
                              .map((type) => DropdownMenuItem(
                              value: type['value'].toString(),
                              child: Text(type['name'].toString())
                              ))
                              .toList(),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Pilih tipe identitas yang benar";
                            } else {
                              return null;
                            }
                          }
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    initialValue: nomor_identitas.toString(),
                    onChanged: (value) {
                      setState(() {
                        nomor_identitas = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        addError(error: 'Masukkan nomor identitas yang benar');
                        return "Masukkan nomor identitas yang benar";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Nomor Identitas",
                      hintText: "Masukan Nomor Identitas anda",
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      //
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    initialValue: alamat,
                    onChanged: (value) {
                      setState(() {
                        alamat = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        addError(error: 'Masukkan alamat yang benar');
                        return "Masukkan alamat yang benar";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Alamat",
                      hintText: "Masukan Alamat anda",
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      //
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      )
    );
  }
}
