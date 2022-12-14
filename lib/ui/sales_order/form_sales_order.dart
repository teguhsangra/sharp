import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/components/rounded_input_field.dart';
import 'package:telkom/model/customer.dart';
import 'package:telkom/model/location.dart';
import 'package:telkom/model/product.dart';
import 'package:telkom/model/room.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';
import 'package:telkom/ui/request_order/detail_request_order.dart';
import 'package:telkom/ui/home/home_screen.dart';

class FormSalesOrderScreen extends StatefulWidget {
  const FormSalesOrderScreen({super.key});

  @override
  State<StatefulWidget> createState() => FormSalesOrderState();
}

class FormSalesOrderState extends State<FormSalesOrderScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final formBottom = GlobalKey<FormState>();
  final formCustomer = GlobalKey<FormState>();

  var user = {};
  List requestOrders = [];
  late List listCustomer = <Customer>[];
  List customers = <Customer>[];

  late List listLocation = <Location>[];
  List locations = <Location>[];

  late List listProduct = <Product>[];
  List products = <Room>[];

  bool isQty = false;
  bool isProduct = false;
  bool isEditItem = false;
  bool isListFilter = false;
  bool isSubmitListFilter = false;
  bool isAddCustomer = true;
  var indexItem;
  var indexLocation;
  var file_1;
  var file_2;

  var codeCustomer;
  var typeCustomer = 'person';
  var nameCustomer;
  var emailCustomer;
  var phoneCustomer = '';
  var typeIdentityCustomer = 'id_cards';
  var noIdentity = '';

  var code;
  var name;
  var customer_id;
  var customer_name;
  var room_id;
  var roomName;
  var remarks;
  var evidence_1;
  var evidence_2;
  int total_price = 0;

  String isType = 'notProduct';
  String nameProduct = '';
  int qty = 0;
  int price = 0;

  var selectedIndexProduct = null;
  var selectedNameProduct = null;
  var selectedPriceProduct = '0';

  var selectedIndexCustomer = null;
  var selectedNameCustomer;

  var selectedIndexLocation = null;
  var selectedNameLocation;

  var selectedIndexAsset = null;
  var selectedNameAsset;

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

  @override
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
    getCode();
    getCodeCustomer();
    getCustomer();
    customers = listCustomer;
    getLocation();
    locations = listLocation;
    getProduct();
    products = listProduct;
  }

  void getCode() async {
    var res = await Network().getData('request_orders-get-code');

    if (res.statusCode == 201) {
      var resultData = jsonDecode(res.body);
      setState(() {
        code = resultData['data'];
      });
    }
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

  void getCustomer() async {
    var res = await Network()
        .getData('customers');

    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);

      setState(() {
        listCustomer.clear();
        resultData['data'].forEach((v) {
          listCustomer.add(Customer.fromJson(v));
        });
      });
    }
  }

  void getLocation() async {
    var res = await Network().getData('locations');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        listLocation.clear();
        resultData['data'].forEach((v) {
          listLocation.add(Location.fromJson(v));
        });
      });
    }
  }

  void getProduct() async {

    var res = await Network().getData('products?tenant_id=${user['tenant_id']}');
    var resultData = jsonDecode(res.body);
    // print(tenant_id);
    if (res.statusCode == 200 || res.statusCode == 201) {


      setState(() {
        listProduct.clear();
        resultData['data'].forEach((v) {
          listProduct.add(Product.fromJson(v));
        });
      });
    }
  }

  void addCustomer() async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.95,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Text('Form Add Customer',
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    SizedBox(height: 15.0),
                    Expanded(
                      child: ListView(
                        children: [
                          Form(
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
                          )
                        ],
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
                          Navigator.pop(context);
                          saveCustomer();
                        },
                        child: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {

    });
  }

  void saveCustomer() async{
    if(formCustomer.currentState!.validate())
    {
      var data =
      {
        "tenant_id": user['tenant_id'],
        "code":codeCustomer,
        "name":nameCustomer,
        "type":typeCustomer,
        "email":emailCustomer,
        "phone":phoneCustomer,
        "identity_type":typeIdentityCustomer,
        "identity_number":noIdentity

      };

      var res = await Network().postUrl('customers', data);
      var body = json.decode(res.body);
      if(res.statusCode == 200 || res.statusCode == 201)
      {
        getCustomer();
        setState(() {
          selectedIndexCustomer = body['data']['id'];
          selectedNameCustomer = nameCustomer;
          isAddCustomer = false;
          codeCustomer = '';
          typeCustomer = 'person';
          nameCustomer = '';
          emailCustomer= '';
          phoneCustomer = '';
          typeIdentityCustomer = 'id_cards';
          noIdentity = '';
        });
      }



    }

  }

  void addItemOrders() async {
    var availability = true;
    for (var orderDetail in requestOrders) {
      if (orderDetail['isType'] == 'product') {
        if (orderDetail['product_id'] == selectedIndexAsset) {
          availability = false;
          break;
        }
      } else {
        if (orderDetail['name'] == name) {
          availability = false;
          break;
        }
      }
    }
    if (availability) {
      setState(() {
        requestOrders.add({
          'id': selectedIndexAsset,
          'name': selectedNameAsset,
          'quantity': qty,
          'price': price
        });
        isQty = false;
        isProduct = false;

        isType = 'notProduct';
        selectedIndexAsset = null;
        selectedNameAsset = null;
        nameProduct = '';
        qty = 0;
        price = 0;
      });
      Navigator.pop(context);
    } else {
      SnackBar(
        content: Text(
          'You already select this product',
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
      );
    }
    countPrice();
  }

  void editItemOrders() async {
    var item = requestOrders[indexItem];

    setState(() {
      item['isType'] = isType.toString();
      item['product_id'] = selectedIndexProduct;
      item['product_name'] = selectedNameProduct;
      item['name'] = nameProduct;
      item['quantity'] = qty;
      item['price'] = price;

      isQty = false;
      isProduct = false;
      indexItem = null;
      isType = 'notProduct';
      selectedIndexProduct = null;
      selectedNameProduct = null;
      nameProduct = '';
      qty = 0;
      price = 0;
      isEditItem = false;
    });
    Navigator.pop(context);
    countPrice();
  }

  void removeItemOrders() async {
    requestOrders.removeAt(indexItem);
    indexItem = null;
    countPrice();
  }

  void bottomSheetItem() async {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              alignment: Alignment.topCenter,
              height: size.height * 0.95,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Text('Tambahkan Pesanan Barang',
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    SizedBox(height: 20.0),
                    SingleChildScrollView(
                      child: Form(
                        key: formBottom,
                        child: Column(
                          children: [

                            SizedBox(height: 20.0),
                            (isType == 'product'
                                ? Row(
                              children: [
                                Text(
                                  'Produk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 200,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xFFE50404),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text('Pilih Product'),
                                      ),
                                      SizedBox(
                                        width: 50,
                                      ),
                                      Icon(Icons.arrow_drop_down_circle,
                                          color: Color(0xFFE50404))
                                    ],
                                  ),
                                )
                              ],
                            )
                                : TextFormField(
                              initialValue: nameProduct.toString(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelText: "Nama",
                              ),
                              onChanged: (value) {
                                // print(value);
                                setState(() {
                                  nameProduct = value;
                                });
                              },
                              validator: (value) {
                                if (isType == 'notProduct') {
                                  if (value!.isEmpty) {
                                    return "Nama barang tidak boleh kosong";
                                  } else {
                                    return null;
                                  }
                                }
                              },
                            )),
                            if (isProduct == true) SizedBox(height: 20.0),
                            if (isProduct == true)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Produk tidak boleh kosong',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red)),
                              ),
                            SizedBox(height: 30.0),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Kuantitas',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              padding: EdgeInsets.zero,
                              child: Row(
                                children: <Widget>[
                                  qty != 0
                                      ? Container(
                                    width: 50,
                                    height: 50,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                      BorderRadius.circular(40),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Color(0xFFE50404),
                                        width: 1,
                                      ),
                                    ),
                                    child: new IconButton(
                                      icon: new Icon(Icons.remove,
                                          size: 20),
                                      onPressed: () {
                                        setState(() {
                                          qty--;
                                          if (qty == 0) {
                                            isQty = true;
                                          }
                                        });
                                      },
                                    ),
                                  )
                                      : new Container(),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  new Text(qty.toString()),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Color(0xFFE50404),
                                        width: 1,
                                      ),
                                    ),
                                    child: new IconButton(
                                        icon: new Icon(Icons.add, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            qty++;
                                            isQty = false;
                                          });
                                        }),
                                  )
                                ],
                              ),
                            ),
                            if (isQty == true) SizedBox(height: 20.0),
                            if (isQty == true)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Kuantitas harus di isi',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red)),
                              ),
                            SizedBox(height: 30.0),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Harga',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              initialValue:price.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                // print(value);
                                setState(() {
                                  price = int.parse(value);
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelText: "",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Harga harus di isi";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: 50,
                              width: size.width * 0.9,
                              decoration: BoxDecoration(
                                  color: Color(0xFFE50404),
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextButton(
                                onPressed: () {
                                  if (qty == 0) {
                                    setState(() {
                                      isQty = true;
                                    });
                                  } else if (isType == 'product' &&
                                      selectedIndexProduct == null) {
                                    setState(() {
                                      isProduct = true;
                                    });
                                  } else {
                                    if (formBottom.currentState!.validate()) {
                                      if (isEditItem == false) {
                                        addItemOrders();
                                      } else {
                                        editItemOrders();
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {
      setState(() {
        indexItem = null;
      });
    });
  }

  void customerBottomSheet() async {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listCustomer;
                          } else {
                            final suggestions = listCustomer.where((customer) {
                              final customerName = customer.name.toLowerCase();
                              final input = value.toLowerCase();

                              return customerName.contains(input);
                            }).toList();

                            setState(() {
                              customers = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Customer',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (isListFilter == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndexCustomer = 0;
                                selectedNameCustomer = null;
                                isListFilter = false;
                                isSubmitListFilter = true;
                              });
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          var item = customers[index];
                          return CheckboxListTile(
                            title: Text(customers[index].name),
                            value:
                            selectedIndexCustomer == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndexCustomer = item.id;
                                  selectedNameCustomer = item.name;
                                  isSubmitListFilter = true;
                                  isListFilter = true;
                                } else {
                                  selectedIndexCustomer = null;
                                  selectedNameCustomer = null;
                                  isSubmitListFilter = false;
                                  isListFilter = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (isSubmitListFilter != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFFE50404),
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isSubmitListFilter = false;
                              customers = listCustomer;
                            });
                            updateCustomer();
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {
      // print('test');
      // if(isSubmitListFilter == false){
      //   setState((){
      //     selectedIndexCustomer = null;
      //     selectedNameCustomer = null;
      //   });
      // }
    });
  }

  void locationBottomSheet() async {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listLocation;
                          } else {
                            final suggestions = listLocation.where((location) {
                              final locationName = location.name.toLowerCase();
                              final input = value.toLowerCase();

                              return locationName.contains(input);
                            }).toList();

                            setState(() {
                              locations = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Location',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (isListFilter == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndexLocation = 0;
                                selectedNameLocation = null;
                                isListFilter = false;
                                isSubmitListFilter = true;
                                locations = listLocation;
                              });
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          var item = locations[index];
                          return CheckboxListTile(
                            title: Text(locations[index].name),
                            value: selectedIndexLocation == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndexLocation = item.id;
                                  selectedNameLocation = item.name;
                                  isSubmitListFilter = true;
                                  isListFilter = true;
                                } else {
                                  selectedIndexLocation = null;
                                  selectedNameLocation = null;
                                  isSubmitListFilter = false;
                                  isListFilter = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (isSubmitListFilter != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFFE50404),
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isSubmitListFilter = false;
                              locations = listLocation;
                            });
                            updateRoom();
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {

    });
  }

  void productBottomSheet() async {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              width: size.width,
              height: size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listProduct;
                          } else {
                            final suggestions = listProduct.where((product) {
                              final productName = product.name.toLowerCase();
                              final input = value.toLowerCase();

                              return productName.contains(input);
                            }).toList();

                            setState(() {
                              products = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Product',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (isListFilter == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndexProduct = 0;
                                selectedNameProduct = null;
                                isListFilter = false;
                                isSubmitListFilter = true;
                                products = listProduct;
                              });
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                          )
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var item = products[index];
                          return CheckboxListTile(
                            title: Text(products[index].name),
                            value: selectedIndexProduct == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndexProduct = item.id;
                                  selectedNameProduct = item.name;
                                  isSubmitListFilter = true;
                                  isListFilter = true;
                                } else {
                                  selectedIndexProduct = null;
                                  selectedNameProduct = null;
                                  isSubmitListFilter = false;
                                  isListFilter = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (isSubmitListFilter != false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Color(0xFFE50404),
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isSubmitListFilter = false;
                              products = listProduct;
                            });
                            updateRoom();
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {

    });
  }

  void updateCustomer() async {
    setState(() {});
  }

  void updateRoom() async {
    setState(() {});
  }

  void submitRequestOrder() async {
    FocusScope.of(context).unfocus();
    bool isSubmit = true;
    bool isLoadingSubmit = true;



    // var data = {
    //   "tenant_id": user['tenant_id'],
    //   "status": 'submission',
    //   "code": code,
    //   "name": name,
    //   "employee_id": user['person']['employee']['id'],
    //   "customer_id": selectedIndexCustomer,
    //   "room_id": selectedIndexRoom,
    //   "total_price": total_price,
    //   "remarks": remarks,
    //   "evidence_1": evidence_1,
    //   "evidence_2": evidence_2,
    //   "timezone": listRoom[indexRoom].location.timezone,
    //   "request_order_detail": jsonEncode(requestOrders)
    // };
    //
    // if (selectedIndexCustomer == null || selectedIndexRoom == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //       'Customer atau Ruangan harus di isi',
    //       style: TextStyle(fontSize: 18),
    //       textAlign: TextAlign.center,
    //     ),
    //     backgroundColor: Colors.red,
    //     duration: Duration(seconds: 3),
    //     shape: StadiumBorder(),
    //     margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    //     behavior: SnackBarBehavior.floating,
    //     elevation: 0,
    //     action: SnackBarAction(
    //       textColor: Colors.white,
    //       label: 'x',
    //       onPressed: () {
    //         // Code to execute.
    //       },
    //     ),
    //   ));
    // } else {
    //   if (_formKey.currentState!.validate()) {
    //     showAlertDialog(context);
    //     var res = await Network().postRequestOrder('request_orders', data);
    //     var body = json.decode(res.body);
    //     if(res.statusCode == 201 || res.statusCode == 200){
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           backgroundColor: Colors.green,
    //           content: const Text('Sukses tambahkan pesanan Permintaan'),
    //           action: SnackBarAction(
    //             textColor: Colors.white,
    //             label: 'x',
    //             onPressed: () {
    //               // Code to execute.
    //             },
    //           ),
    //           duration: Duration(seconds: 3),
    //           shape: StadiumBorder(),
    //           margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    //           behavior: SnackBarBehavior.floating,
    //           elevation: 0,
    //         ),
    //       );
    //       Navigator.of(
    //         context,
    //       ).pushAndRemoveUntil(
    //           MaterialPageRoute(
    //             builder: (context) => HomeScreen(),
    //           ),
    //               (route) => false);
    //     }else{
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text(
    //           'Gagal submit form request',
    //           style: TextStyle(fontSize: 18),
    //           textAlign: TextAlign.center,
    //         ),
    //         backgroundColor: Colors.red,
    //         duration: Duration(seconds: 3),
    //         shape: StadiumBorder(),
    //         margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    //         behavior: SnackBarBehavior.floating,
    //         elevation: 0,
    //         action: SnackBarAction(
    //           textColor: Colors.white,
    //           label: 'x',
    //           onPressed: () {
    //             // Code to execute.
    //           },
    //         ),
    //       ));
    //     }
    //
    //   }
    // }
  }

  void countPrice() async {
    var total = 0;
    for (var items in requestOrders) {
      int price = items['price'] * items['quantity'];
      total = total + price;
    }
    setState(() {
      total_price = total;
    });
  }

  void _getFromCamera(index) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      var file_image = File(pickedFile.path);
      // Get mime type
      final _image = await file_image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: _image);
      // convert to base64
      Uint8List? imagebytes = await file_image.readAsBytes();
      String base64string = base64.encode(imagebytes!);

      setState(() {
        if (index == 1) {
          file_1 = file_image;
          evidence_1 = "data:" + mime.toString() + ";base64," + base64string;
        }
        if (index == 2) {
          file_2 = file_image;
          evidence_2 = "data:" + mime.toString() + ";base64," + base64string;
        }
      });
    }
  }

  void _getFromGallery(index) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      var file_image = File(pickedFile.path);
      // Get mime type
      final _image = await file_image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: _image);
      // convert to base64
      Uint8List? imagebytes = await file_image.readAsBytes();
      String base64string = base64.encode(imagebytes!);

      setState(() {
        if (index == 1) {
          file_1 = file_image;
          evidence_1 = "data:" + mime.toString() + ";base64," + base64string;
        }
        if (index == 2) {
          file_2 = file_image;
          evidence_2 = "data:" + mime.toString() + ";base64," + base64string;
        }
      });
    }
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
          "Form Sales Order",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
              },
              icon: Icon(Icons.notifications, color: Colors.black),
            ),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xffD9D9D9),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/hero_profile.png",
                  height: 40.0,
                  width: 40.0,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height / 30,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Kode',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 50,
                  child: TextFormField(
                    initialValue: code,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: "",
                    ),
                    onChanged: (value) {
                      // print(value);
                      setState(() {
                        code = value;
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
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nama',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: "",
                    ),
                    onChanged: (value) {
                      // print(value);
                      setState(() {
                        name = value;
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
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text('Location',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        locationBottomSheet();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xFFE1120F),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: size.height / 4,
                              padding: new EdgeInsets.all(10),
                              child: Text(
                                selectedNameLocation != null
                                    ? selectedNameLocation
                                    : 'Pilih Location',
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                  fontSize: 13.0,
                                  fontFamily: 'Roboto',
                                  color: new Color(0xFF212121),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(Icons.arrow_drop_down_circle,
                                color: Color(0xFFE1120F))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text('Customer',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        customerBottomSheet();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xFFE1120F),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: size.height / 4,
                              padding: new EdgeInsets.all(10),
                              child: Text(
                                selectedNameCustomer != null
                                    ? selectedNameCustomer
                                    : 'Pilih Customer',
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                  fontSize: 13.0,
                                  fontFamily: 'Roboto',
                                  color: new Color(0xFF212121),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(Icons.arrow_drop_down_circle,
                                color: Color(0xFFE1120F))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                isAddCustomer  ?
                GestureDetector(
                  onTap: () {
                    addCustomer();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFFE1120F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            'Tambah Customer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Icon(Icons.add, color: Colors.white)
                      ],
                    ),
                  ),
                )
                    : new Container(),

                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text('Product',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        productBottomSheet();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xFFE1120F),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: size.height / 4,
                              padding: new EdgeInsets.all(10),
                              child: Text(
                                selectedNameProduct != null
                                    ? selectedNameProduct
                                    : 'Pilih Product',
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                  fontSize: 13.0,
                                  fontFamily: 'Roboto',
                                  color: new Color(0xFF212121),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(Icons.arrow_drop_down_circle,
                                color: Color(0xFFE1120F))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20,),

                Text('Catatan',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                SizedBox(
                  height: 20,
                ),

                SizedBox(
                  height: 100,
                  child: TextField(
                    onChanged: (value) {
                      // print(value);
                      setState(() {
                        remarks = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Unggah Gambar',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    (file_1 == null
                        ? Column(
                      children: [
                        Text(
                          'Gambar 1',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.vertical(
                                    top: Radius.circular(25.0),
                                  ),
                                ),
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(builder:
                                      (context,
                                      StateSetter setState) {
                                    return Container(
                                      width: size.width,
                                      height: size.height * 0.3,
                                      child: Padding(
                                        padding:
                                        EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 50.0,
                                                height: 5.0,
                                                decoration:
                                                BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .all(Radius
                                                      .circular(
                                                      10.0)),
                                                  color:
                                                  Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 20.0),
                                            Text('Gambar 1',
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    color: Colors
                                                        .black)),
                                            const SizedBox(
                                                height: 20.0),
                                            GestureDetector(
                                              onTap: () async {
                                                _getFromCamera(1);
                                                Navigator.pop(
                                                    context);
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .photo_camera,
                                                    color: Color(
                                                        0xFFE50404),
                                                    size: 28,
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    'Ambil dari kamera',
                                                    style: TextStyle(
                                                        fontSize:
                                                        16),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),

                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                });
                          },
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6ECF6),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.photo_camera,
                                  color: Color(0xFFE50404),
                                  size: 28,
                                ),
                              ),
                              Text('Mengambil gambar',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ))
                            ],
                          ),
                        ),
                      ],
                    )
                        : Container(
                        child: Column(
                          children: [
                            Text(
                              'Gambar 1',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FullScreenWidget(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  file_1,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.vertical(
                                        top: Radius.circular(25.0),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (context,
                                          StateSetter setState) {
                                        return Container(
                                          width: size.width,
                                          height: size.height * 0.3,
                                          child: Padding(
                                            padding:
                                            EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 50.0,
                                                    height: 5.0,
                                                    decoration:
                                                    BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          10.0)),
                                                      color:
                                                      Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 20.0),
                                                Text('Gambar 1',
                                                    style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                        FontWeight
                                                            .w700,
                                                        color: Colors
                                                            .black)),
                                                const SizedBox(
                                                    height: 20.0),
                                                GestureDetector(
                                                  onTap: () async {
                                                    _getFromCamera(1);
                                                    Navigator.pop(
                                                        context);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .photo_camera,
                                                        color: Color(
                                                            0xFFE50404),
                                                        size: 28,
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Text(
                                                        'Mengambil gambar',
                                                        style: TextStyle(
                                                            fontSize:
                                                            16),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 40.0),

                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                                color: Color(0xFFE50404),
                                child: const SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: Center(
                                    child: Text.rich(
                                      TextSpan(
                                        children: <InlineSpan>[
                                          WidgetSpan(
                                            alignment:
                                            PlaceholderAlignment
                                                .middle,
                                            child: Icon(
                                              Icons.camera,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          TextSpan(
                                              text: ' foto ulang',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  file_1 = null;
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                                color: Color(0xFFE50404),
                                child: const SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: Center(
                                    child: Text.rich(
                                      TextSpan(
                                        children: <InlineSpan>[
                                          WidgetSpan(
                                            alignment:
                                            PlaceholderAlignment
                                                .middle,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          TextSpan(
                                              text: ' Hapus foto ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))),
                    (file_2 == null
                        ? Column(
                      children: [
                        Text(
                          'Gambar 2',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.vertical(
                                    top: Radius.circular(25.0),
                                  ),
                                ),
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(builder:
                                      (context,
                                      StateSetter setState) {
                                    return Container(
                                      width: size.width,
                                      height: size.height * 0.3,
                                      child: Padding(
                                        padding:
                                        EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 50.0,
                                                height: 5.0,
                                                decoration:
                                                BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .all(Radius
                                                      .circular(
                                                      10.0)),
                                                  color:
                                                  Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 20.0),
                                            Text('Gambar 2',
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    color: Colors
                                                        .black)),
                                            const SizedBox(
                                                height: 20.0),
                                            GestureDetector(
                                              onTap: () async {
                                                _getFromCamera(2);
                                                Navigator.pop(
                                                    context);
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .photo_camera,
                                                    color: Color(
                                                        0xFFE50404),
                                                    size: 28,
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    'Ambil dari kamera',
                                                    style: TextStyle(
                                                        fontSize:
                                                        16),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),

                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                });
                          },
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6ECF6),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.photo_camera,
                                  color: Color(0xFFE50404),
                                  size: 28,
                                ),
                              ),
                              Text('Mengambil gambar',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ))
                            ],
                          ),
                        ),
                      ],
                    )
                        : Container(
                        child: Column(
                          children: [
                            Text(
                              'Gambar 2',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FullScreenWidget(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  file_2,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.vertical(
                                        top: Radius.circular(25.0),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (context,
                                          StateSetter setState) {
                                        return Container(
                                          width: size.width,
                                          height: size.height * 0.3,
                                          child: Padding(
                                            padding:
                                            EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 50.0,
                                                    height: 5.0,
                                                    decoration:
                                                    BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          10.0)),
                                                      color:
                                                      Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 20.0),
                                                Text('Gambar 2',
                                                    style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                        FontWeight
                                                            .w700,
                                                        color: Colors
                                                            .black)),
                                                const SizedBox(
                                                    height: 20.0),
                                                GestureDetector(
                                                  onTap: () async {
                                                    _getFromCamera(2);
                                                    Navigator.pop(
                                                        context);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .photo_camera,
                                                        color: Color(
                                                            0xFFE50404),
                                                        size: 28,
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Text(
                                                        'Mengambil gambar',
                                                        style: TextStyle(
                                                            fontSize:
                                                            16),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 40.0),

                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                                color: Color(0xFFE50404),
                                child: const SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: Center(
                                    child: Text.rich(
                                      TextSpan(
                                        children: <InlineSpan>[
                                          WidgetSpan(
                                            alignment:
                                            PlaceholderAlignment
                                                .middle,
                                            child: Icon(
                                              Icons.camera,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          TextSpan(
                                              text: ' foto ulang',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  file_2 = null;
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                                color: Color(0xFFE50404),
                                child: const SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: Center(
                                    child: Text.rich(
                                      TextSpan(
                                        children: <InlineSpan>[
                                          WidgetSpan(
                                            alignment:
                                            PlaceholderAlignment
                                                .middle,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          TextSpan(
                                              text: ' Hapus foto ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () {
                    bottomSheetItem();
                  },
                  child: Container(
                    width: 230,
                    height: 50,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFFE50404),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            'Tambahkan Pesanan Barang',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Icon(Icons.add, color: Colors.white)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(color: Colors.grey),
                SizedBox(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: requestOrders.length,
                      itemBuilder: (context, index) {
                        var item = requestOrders[index];
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            indexItem = index;
                                          });
                                          removeItemOrders();
                                        },
                                        child: Container(
                                            width: 40,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Color(0xFFE50404),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.delete,
                                              size: 15,
                                              color: Color(0xFFE50404),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isType = item['isType'];
                                            selectedIndexAsset =
                                            item['id'];
                                            selectedNameAsset =
                                            item['name'];
                                            qty = item['quantity'];
                                            price = item['price'];
                                            isEditItem = true;
                                            indexItem = index;
                                          });
                                          bottomSheetItem();
                                        },
                                        child: Container(
                                            width: 40,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Color(0xFFE50404),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 15,
                                              color: Color(0xFFE50404),
                                            )),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        item['isType'] == "product"
                                            ? item['product_name']
                                            : item['name'],
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'QTY: ' +
                                            item['quantity'].toString(),
                                        style: TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(
                                      '${currencyFormat(item['price'] * item['quantity'])}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: Colors.grey),
                          ],
                        );
                      }),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Total price',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ),
                    Text('${currencyFormat(total_price)}',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(color: Colors.grey),
                SizedBox(
                  height: 30,
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
                      submitRequestOrder();
                    },
                    child: const Text(
                      'Kirim',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
