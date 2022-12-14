import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/network/api.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<StatefulWidget> createState() => CustomerScreenState();
}

class CustomerScreenState extends State<CustomerScreen> {
  bool isLoading = false;
  final formCustomer = GlobalKey<FormState>();
  var user = {};

  var codeCustomer;
  var typeCustomer = 'person';
  var nameCustomer;
  var emailCustomer;
  var phoneCustomer = '';
  var typeIdentityCustomer = 'id_cards';
  var noIdentity = '';

  var type = [
    {
      "name": "Pribadi",
      "value": "person"
    },
    {
      "name": "Perusahaan",
      "value": "company"
    }
  ];

  var type_identity = [
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

  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    loadUserData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }
  loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userSession = jsonDecode(localStorage.getString('user').toString());
    setState(() {
      user = userSession;
    });
    getCodeCustomer();
  }
  void getCodeCustomer() async {
    var res = await Network().getData('customers-get-code');

    if (res.statusCode == 201) {
      var resultData = jsonDecode(res.body);
      setState(() {
        codeCustomer = resultData['data'];
      });
    }
  }

  void saveData() async{
    var customer = {
      "tenant_id": user['tenant_id'],
      "code":codeCustomer,
      "name":nameCustomer,
      "type":typeCustomer,
      "email":emailCustomer,
      "phone":phoneCustomer,
      "identity_type":typeIdentityCustomer,
      "identity_number":noIdentity
    };
    if(formCustomer.currentState!.validate())
    {
      Navigator
          .of(context)
          .pop(customer);
    }

  }

  @override
  Widget build(BuildContext context){
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
          "Form Customer",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body:  isLoading
          ? Center(child: CircularProgressIndicator())
          :
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formCustomer,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Kode *',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: TextFormField(
                        initialValue: codeCustomer,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: "",
                        ),
                        onChanged: (value) {
                          // print(value);
                          setState(() {
                            codeCustomer = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Kode harus di isi";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Tipe *',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ),
                    SizedBox(height: 20.0),
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

                            value: typeCustomer,
                            onChanged: (value) {
                              setState(() {
                                typeCustomer = value.toString();
                              });
                            },
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            items: type
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Nama *',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: TextFormField(
                        initialValue: nameCustomer,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: "",
                        ),
                        onChanged: (value) {
                          // print(value);
                          setState(() {
                            nameCustomer = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Nama harus di isi";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email *',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: TextFormField(
                        initialValue: emailCustomer,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: "",
                        ),
                        onChanged: (value) {
                          // print(value);
                          setState(() {
                            emailCustomer = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email harus di isi";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Phone',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: TextFormField(
                        initialValue: phoneCustomer,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: "",
                        ),
                        onChanged: (value) {
                          // print(value);
                          setState(() {
                            phoneCustomer = value;
                          });
                        },
                      ),
                    ),
                    (typeCustomer == 'person' ?
                    Column(
                      children: [
                        SizedBox(height: 20,),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Type Indentity *',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ),
                        SizedBox(height: 20.0),
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

                                value: typeIdentityCustomer,
                                onChanged: (value) {
                                  setState(() {
                                    typeIdentityCustomer = value.toString();
                                  });
                                },
                                decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                                items: type_identity
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Number Identity',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          height: 50,
                          child: TextFormField(
                            initialValue: noIdentity,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: "",
                            ),
                            onChanged: (value) {
                              // print(value);
                              setState(() {
                                noIdentity = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ) :
                    new Container()
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: 50,
              width: size.width * 0.9,
              decoration: BoxDecoration(
                  color: Color(0xFFE50404),
                  borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  saveData();
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );

  }

}