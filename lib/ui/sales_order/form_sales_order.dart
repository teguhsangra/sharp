import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/dialog_customer.dart';
import 'package:telkom/components/dialog_sales_order_detail.dart';
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


  var user = {};
  List requestOrders = [];
  late List listCustomer = <Customer>[];
  List customers = <Customer>[];

  late List listLocation = <Location>[];
  List locations = <Location>[];

  List salesOrders = [];



  bool listSelectedLocation = false;
  bool submitSelectedLocation = false;

  bool listSelectedCustomer = false;
  bool submitSelectedCustomer = false;

  bool isAddCustomer = true;
  var indexLocation;
  var file_1;
  var file_2;



  var code;
  var name;
  var customer_id;
  var customer_name;
  var room_id;
  var roomName;
  var remarks;
  var evidence_1;
  var evidence_2;
  int total_diskon = 0;
  int total_price = 0;
  int total_tax = 0;
  int grand_total = 0;

  String isType = 'notProduct';
  String nameProduct = '';
  int qty = 0;
  int price = 0;


  var selectedLocation = {};
  var selectedCustomer = {};





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
    getCustomer();
    customers = listCustomer;
    getLocation();
    locations = listLocation;
  }

  void getCode() async {
    var res = await Network().getData('sales_orders-get-code?is_inquiry=0');

    if (res.statusCode == 201) {
      var resultData = jsonDecode(res.body);
      print(resultData['data']);
      setState(() {
        code = resultData['data'];
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





  Future openAddCustomerDialog() async {
    var dataCustomer =
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new CustomerScreen();
        },
        fullscreenDialog: true));
    if (dataCustomer != null) {
      saveCustomer(dataCustomer);
    }
  }



  void saveCustomer(dataCustomer)async {

    var res = await Network().postUrl('customers', dataCustomer);
    var body = json.decode(res.body);
    if(res.statusCode == 200 || res.statusCode == 201)
    {
      setState(() {
        selectedCustomer = {'id':body['data']['id'], 'name':dataCustomer['name']};
        isAddCustomer = false;
      });
      getCustomer();
    }

  }


  // void addItemOrders() async {
  //   var availability = true;
  //   for (var orderDetail in requestOrders) {
  //     if (orderDetail['isType'] == 'product') {
  //       if (orderDetail['product_id'] == selectedIndexAsset) {
  //         availability = false;
  //         break;
  //       }
  //     } else {
  //       if (orderDetail['name'] == name) {
  //         availability = false;
  //         break;
  //       }
  //     }
  //   }
  //   if (availability) {
  //     setState(() {
  //       requestOrders.add({
  //         'id': selectedIndexAsset,
  //         'name': selectedNameAsset,
  //         'quantity': qty,
  //         'price': price
  //       });
  //       isQty = false;
  //       isProduct = false;
  //
  //       isType = 'notProduct';
  //       selectedIndexAsset = null;
  //       selectedNameAsset = null;
  //       nameProduct = '';
  //       qty = 0;
  //       price = 0;
  //     });
  //     Navigator.pop(context);
  //   } else {
  //     SnackBar(
  //       content: Text(
  //         'You already select this product',
  //         style: TextStyle(fontSize: 18),
  //         textAlign: TextAlign.center,
  //       ),
  //       backgroundColor: Colors.red,
  //       duration: Duration(seconds: 3),
  //       shape: StadiumBorder(),
  //       margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  //       behavior: SnackBarBehavior.floating,
  //       elevation: 0,
  //       action: SnackBarAction(
  //         textColor: Colors.white,
  //         label: 'x',
  //         onPressed: () {
  //           // Code to execute.
  //         },
  //       ),
  //     );
  //   }
  //   countPrice();
  // }
  //
  // void editItemOrders() async {
  //   var item = requestOrders[indexItem];
  //
  //   setState(() {
  //     item['isType'] = isType.toString();
  //     item['product_id'] = selectedIndexProduct;
  //     item['product_name'] = selectedNameProduct;
  //     item['name'] = nameProduct;
  //     item['quantity'] = qty;
  //     item['price'] = price;
  //
  //     isQty = false;
  //     isProduct = false;
  //     indexItem = null;
  //     isType = 'notProduct';
  //     selectedIndexProduct = null;
  //     selectedNameProduct = null;
  //     nameProduct = '';
  //     qty = 0;
  //     price = 0;
  //     isEditItem = false;
  //   });
  //   Navigator.pop(context);
  //   countPrice();
  // }
  //
  void removeItemOrders(indexItem) async {
    salesOrders.removeAt(indexItem);
    indexItem = null;
    countPrice();
  }

  void openAddProdukDialog() async{
    if(selectedCustomer.length > 0)
    {
      var save =
      await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) {
            return new SalesOrderDetailDialogScreen.add(selectedCustomer['id'],null);
          },
          fullscreenDialog: true));
      if (save != null) {
        addItemOrders(save);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lokasi harus diisi',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            shape: StadiumBorder(),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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

  void openEditProdukDialog(value) async{
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute(
        builder: (BuildContext context) {
          return new SalesOrderDetailDialogScreen.edit(selectedCustomer['id'],value);
        },
        fullscreenDialog: true,
      ),
    )
        .then((newSave) {
      if (newSave != null) {
        setState(() => salesOrders[salesOrders.indexOf(value)] = newSave);
        countPrice();
      }
    });

  }

  void addItemOrders(dataOrder) async {
    setState(() {
      salesOrders.add(dataOrder);
    });
    countPrice();
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
                        if (listSelectedCustomer == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCustomer = {};
                                listSelectedCustomer = false;
                                submitSelectedCustomer = true;
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
                            selectedCustomer['id'] == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedCustomer = {'id':item.id,'name':item.name};

                                  submitSelectedCustomer = true;
                                  listSelectedCustomer = true;
                                } else {
                                  selectedCustomer = {};

                                  submitSelectedCustomer = false;
                                  listSelectedCustomer = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (submitSelectedCustomer != false)
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
                              submitSelectedCustomer = false;
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
                        if (listSelectedLocation == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLocation = {};

                                listSelectedLocation = false;
                                submitSelectedLocation = true;

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
                            value: selectedLocation['id'] == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedLocation = {'id': item.id, 'name': item.name};

                                  submitSelectedLocation = true;
                                  listSelectedLocation = true;
                                } else {
                                  selectedLocation = {};

                                  submitSelectedLocation = false;
                                  listSelectedLocation = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (submitSelectedLocation != false)
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
                              submitSelectedLocation = false;
                              locations = listLocation;
                            });
                            refreshSelected();
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

  void refreshSelected() async {
    setState(() {});
  }

  void submitRequestOrder() async {
    bool isValid = false;
    FocusScope.of(context).unfocus();

    if(selectedLocation.length == 0)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lokasi harus diisi',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            shape: StadiumBorder(),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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

    }else{
      isValid = true;
    }

    if(selectedCustomer.length == 0)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Customer harus diisi',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            shape: StadiumBorder(),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
    }else{
      isValid = true;
    }

    if(salesOrders.length == 0)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan barang harus diisi',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            shape: StadiumBorder(),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
    }else{
      isValid = true;
    }

    if(isValid == true){
      if (_formKey.currentState!.validate()) {
        var data = {
          "tenant_id": user['tenant_id'],
          "location_id": selectedLocation['id'],
          "customer_id": selectedCustomer['id'],
          "contact_id": null,
          "emergency_contact_id": null,
          "primary_product_id": salesOrders[0]['product_id'],
          "code" : code,
          "name":name,
          "is_inquiry" : false, // Harus diisi dengan nilai false
          "has_contract" : false, // Harus diisi dengan nilai true
          "is_renewal" : false, // Harus diisi dengan nilai false
          "status" : "draft",
          "renewal_status" : "on renewal", // Harus diisi dengan nilai on renewal
          "started_at" : formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()), // Isian dari user dan harus diisi
          "ended_at" : formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()), // Isian dari user dan harus diisi
          "signed_at" : formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()), // Isian dari user dan harus diisi
          "term" : "month", // Harus diisi dan diambil dari konfigurasi product
          "term_of_payment" : "annually", // Harus diisi dengan nilai anually
          "term_notice_period" : 3, // Harus diisi dengan nilai 3
          "tax_percentage" : 11, // Diambil dari postman login di bagian tenant
          "length_of_term" : 1, // Isian dari user dan harus diisi
          "total_cost" : 0, // Harus diisi dengan nilai 0
          "total_price" : total_price, // Harus diisi dengan nilai sesuai pilihan produk yang di kali dengan length of term dan di kali dengan quantity
          "total_discount" : total_diskon, // Harus diisi dengan nilai 0
          "total_tax" : total_tax,
          "sales_order_details": jsonEncode(salesOrders),
          'drafted_by': user['name']
        };

        var res = await Network().postRequestOrder('sales_orders', data);
        var body = json.decode(res.body);
        if(res.statusCode == 201 || res.statusCode == 200){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: const Text('Sukses tambahkan pesanan Permintaan'),
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
          Navigator.pop(context, 'refresh');
        }

      }
    }
  }

  void countPrice() async {
    var price = 0;
    var diskon =0;
    var pajak=0;
    var service = 0;


    for (var items in salesOrders) {
      int item_price = items['price'] * int.parse(items['quantity']);
      price = price + item_price;

      int item_diskon = int.parse(items['discount']);
      diskon = diskon + item_diskon;

      int item_tax = items['tax'].toInt();
      pajak = pajak + item_tax;

      int item_service = items['service_charge'].toInt();
      service = service+item_service;
    }
    setState(() {
      total_diskon = diskon;
      total_price = price;
      total_tax = pajak;
      grand_total = price - diskon + service + pajak;
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  color: Colors.white,
                  child: Column(
                    children: [
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
                        child: TextFormField(
                          autofocus: true,
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
                      Lokasi(),
                      SizedBox(
                        height: 30,
                      ),
                      Klien(),
                      SizedBox(
                        height: 30,
                      ),
                      isAddCustomer  ?
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TambahKlien(),
                      )
                          : new Container(),

                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(height: 20,),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:  Text('Catatan',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                      ),
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
                    ],
                  ),
                ),



                SizedBox(height: 20,),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top:20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            openAddProdukDialog();
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
                      ),
                      SizedBox(height: 20,),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Detail Pesanan Barang',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey),
                      SizedBox(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: salesOrders.length,
                            itemBuilder: (context, index) {
                              var item = salesOrders[index];
                              return Container(
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item['name'],
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item['quantity'].toString()+' x '+currencyFormat(item['price']),
                                              style: TextStyle(
                                                fontSize: 14,),
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Diskon', style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey
                                                    ),),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('${currencyFormat(int.parse(item['discount']))}', style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black
                                                    ),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 50,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Tax', style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey
                                                    ),),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('${currencyFormat(item['tax'].toInt() )}', style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black
                                                    ),),
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                          SizedBox(height: 20,),
                                          Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Total', style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey
                                                ),),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('${currencyFormat(item['price'] * int.parse(item['quantity']) - int.parse(item['discount']) +  item['service_charge'].toInt() + item['tax'].toInt() )}', style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black
                                                ),),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      width: 250,
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            removeItemOrders(index);
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
                                        SizedBox(width: 10,),
                                        GestureDetector(
                                          onTap: () {

                                            openEditProdukDialog(item);
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
                                        )
                                      ],
                                    ),
                                    Divider(color: Colors.grey,)
                                  ],
                                ),
                              );
                            }),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Total Diskon',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                          Text('${currencyFormat(total_diskon)}',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Total Harga',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                          Text('${currencyFormat(total_price)}',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Total Pajak',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                          Text('${currencyFormat(total_tax)}',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Total Keseluruhan',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                          Text('${currencyFormat(total_price)}',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black))
                        ],
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        height: 100,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              height: 50,
              width: size.width,
              decoration: BoxDecoration(
                  color: Color(0xFFE50404),
                  borderRadius: BorderRadius.circular(18)),
              child: TextButton(
                onPressed: () {
                  submitRequestOrder();
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget Lokasi(){
    Size size = MediaQuery.of(context).size;
     return  Column(
       children: [
         Align(
           alignment: Alignment.centerLeft,
           child: Text('Lokasi',
               style: TextStyle(
                   fontSize: 16.0,
                   fontWeight: FontWeight.w600,
                   color: Colors.black)),
         ),
         SizedBox(
           height: 20,
         ),
         GestureDetector(
           onTap: () {
             locationBottomSheet();
           },
           child: Container(
             padding: EdgeInsets.all(5),
             decoration: BoxDecoration(
               shape: BoxShape.rectangle,
               borderRadius: BorderRadius.circular(10),
               color: Colors.white,
               border: Border.all(
                 color: Color(0xFFE1120F),
                 width: 1,
               ),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Container(
                   width: size.height / 4,
                   padding: new EdgeInsets.all(10),
                   child: Text(
                     selectedLocation.length > 0
                         ? selectedLocation['name']
                         : 'Pilih Lokasi',
                     overflow: TextOverflow.ellipsis,
                     style: new TextStyle(
                       fontSize: 13.0,
                       fontFamily: 'Roboto',
                       color: new Color(0xFF212121),
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 Icon(Icons.arrow_drop_down_circle,
                     color: Color(0xFFE1120F))
               ],
             ),
           ),
         )
       ],
     );
  }

  Widget Klien(){
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Klien',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            customerBottomSheet();
          },
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(
                color: Color(0xFFE1120F),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: size.height / 4,
                  padding: new EdgeInsets.all(10),
                  child: Text(
                    selectedCustomer.length >0
                        ? selectedCustomer['name']
                        : 'Pilih Klien',
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                      fontSize: 13.0,
                      fontFamily: 'Roboto',
                      color: new Color(0xFF212121),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down_circle,
                    color: Color(0xFFE1120F))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget TambahKlien(){
    return GestureDetector(
      onTap: () {
        openAddCustomerDialog();
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
                'Tambah Klien',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Icon(Icons.add, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
