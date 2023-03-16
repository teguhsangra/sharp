import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/model/location.dart';
import 'package:telkom/model/vendor.dart';
import 'package:telkom/network/api.dart';

import '../../components/dialog_produk_category.dart';
import '../../model/product.dart';

class FormAssetScreen extends StatefulWidget {
  final dynamic editData;
  final int location_id;

  FormAssetScreen.add(this.location_id, this.editData);

  FormAssetScreen.edit(this.location_id, this.editData);

  @override
  State<StatefulWidget> createState() => FormAssetState();
}

class FormAssetState extends State<FormAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isProduct = false;
  var user = {};
  late List listLocation = <Location>[];
  List locations = <Location>[];
  late List listVendor = <Vendor>[];
  List vendors = <Vendor>[];
  late List listProduct = <Product>[];
  List products = <Product>[];

  bool listSelectedLocation = false;
  bool submitSelectedLocation = false;
  bool listSelectedVendor = false;
  bool submitSelectedVendor = false;
  bool listSelectedProduct = false;
  bool submitSelectedProduct = false;

  var selectedLocation = {};
  var selectedVendor = {};
  var selectedProduct = {};
  var selectedCategory = {};

  var code;

  var editData;

  showAlertDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
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
    getLocation();
    locations = listLocation;
    getVendor();
    vendors = listVendor;
    getProduct();
    products = listProduct;
  }

  void getCode() async {
    var res = await Network().getData('assets-get-code');

    if (res.statusCode == 201) {
      var resultData = jsonDecode(res.body);

      setState(() {
        code = resultData['data'];
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

  void getVendor() async {
    var res = await Network().getData('vendors');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        listVendor.clear();
        resultData['data'].forEach((v) {
          listVendor.add(Vendor.fromJson(v));
        });
      });
    }
  }

  void getProduct() async {
    var res =
        await Network().getData('products?tenant_id=${user['tenant_id']}');
    if (res.statusCode == 200) {
      var resultData = jsonDecode(res.body);
      setState(() {
        listProduct.clear();
        resultData['data'].forEach((v) {
          listProduct.add(Product.fromJson(v));
        });
      });
    }
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
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
                            value: selectedLocation['id'] == item.id
                                ? true
                                : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedLocation = {
                                    'id': item.id,
                                    'name': item.name
                                  };

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
        }).whenComplete(() {});
  }

  void vendorBottomSheet() async {
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey))),
                        onChanged: (value) {
                          // print(value);
                          if (value.isEmpty) {
                            final suggestions = listVendor;
                          } else {
                            final suggestions = listVendor.where((vendor) {
                              final locationName = vendor.name.toLowerCase();
                              final input = value.toLowerCase();

                              return locationName.contains(input);
                            }).toList();

                            setState(() {
                              vendors = suggestions;
                            });
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Brand',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (listSelectedVendor == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVendor = {};

                                listSelectedVendor = false;
                                submitSelectedVendor = true;

                                vendors = listVendor;
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
                        itemCount: vendors.length,
                        itemBuilder: (context, index) {
                          var item = vendors[index];
                          return CheckboxListTile(
                            title: Text(vendors[index].name),
                            value:
                                selectedVendor['id'] == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedVendor = {
                                    'id': item.id,
                                    'name': item.name
                                  };

                                  submitSelectedVendor = true;
                                  listSelectedVendor = true;
                                } else {
                                  selectedVendor = {};

                                  submitSelectedVendor = false;
                                  listSelectedVendor = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (submitSelectedVendor != false)
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
                              submitSelectedVendor = false;
                              vendors = listVendor;
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
        }).whenComplete(() {});
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
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
                              final locationName = product.name.toLowerCase();
                              final input = value.toLowerCase();

                              return locationName.contains(input);
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
                        Text('Produk',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        if (listSelectedProduct == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedProduct = {};

                                listSelectedProduct = false;
                                submitSelectedProduct = true;

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
                            value:
                                selectedProduct['id'] == item.id ? true : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedProduct = {
                                    'id': item.id,
                                    'name': item.name
                                  };

                                  submitSelectedProduct = true;
                                  listSelectedProduct = true;
                                } else {
                                  selectedProduct = {};

                                  submitSelectedProduct = false;
                                  listSelectedProduct = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (submitSelectedProduct != false)
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
                              submitSelectedProduct = false;
                              products = listProduct;
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
        }).whenComplete(() {});
  }

  void refreshSelected() async {
    setState(() {});
  }

  void submitAddAsset() async {
    bool isValid = false;
    FocusScope.of(context).unfocus();

    if (selectedLocation.length == 0 ||
        selectedVendor.length == 0 ||
        selectedProduct.length == 0) {
      alertDialogForm();
    } else {
      isValid = true;
    }

    if (isValid == true) {
      if (_formKey.currentState!.validate()) {
        var data = {
          "tenant_id": user['tenant_id'],
          "location_id": selectedLocation['id'],
          "vendor_id": selectedVendor['id'],
          "product_id": selectedProduct['id'],
          "code": code,
          "name": selectedProduct['name'],
          "brand": selectedVendor['name'], // Harus diisi dengan nilai false
          "can_be_rented": false, // Harus diisi dengan nilai true
          "can_be_sold": true
        };
        showAlertDialog(context);
        try {
          var res = await Network().postUrl('assets', data);
          var body = json.decode(res.body);

          if (res.statusCode == 201 || res.statusCode == 200) {
            await Future.delayed(const Duration(milliseconds: 2000), () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).pop('success');
            });
          }
        } on TimeoutException {
          alertDialogFail();
        } catch (e) {
          alertDialogFail();
        }
      }
    }
  }

  void alertDialogForm() {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        enableDrag: false,
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
              height: size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 30,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Image.asset(
                          "assets/images/no_image_pelaporan.png",
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Mohon lengkapi isian form, nama, lokasi, Brand dan Produk tidak boleh kosong.',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  void alertDialogFail() {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        enableDrag: false,
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
              height: size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 30,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Image.asset(
                          "assets/images/no_image_pelaporan.png",
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Gagal submit sales order, mohon dicoba kembali.',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Form Tambah Barang",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: Column(
                            children: [
                              Brand(),
                              SizedBox(height: 20.0),
                              Lokasi(),
                              SizedBox(
                                height: 20,
                              ),
                              ProductCategory(),
                              SizedBox(
                                height: 20,
                              ),
                              _Product(),
                              SizedBox(height: 20.0),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Serial Number',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black)),
                              ),
                              SizedBox(height: 20.0),
                              Container(
                                child: TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
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
                        submitAddAsset();
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

  Widget Lokasi() {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(right: 20, top: 10, bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                child: Text('Lokasi',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                alignment: Alignment.centerLeft,
              ),
              GestureDetector(
                onTap: () {
                  locationBottomSheet();
                },
                child: Text('Lihat semua',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
              )
            ],
          ),
          if (selectedLocation.length > 0)
            Container(
              width: size.height / 2,
              margin: EdgeInsets.only(top: 20),
              child: Text(
                selectedLocation.length > 0 ? selectedLocation['name'] : '',
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: 13.0,
                  fontFamily: 'Roboto',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget Brand() {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(right: 20, top: 10, bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                child: Text('Brand',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                alignment: Alignment.centerLeft,
              ),
              GestureDetector(
                onTap: () {
                  vendorBottomSheet();
                },
                child: Text('Lihat semua',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
              )
            ],
          ),
          if (selectedVendor.length > 0)
            Container(
              width: size.height / 2,
              margin: EdgeInsets.only(top: 20),
              child: Text(
                selectedVendor.length > 0 ? selectedVendor['name'] : '',
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: 13.0,
                  fontFamily: 'Roboto',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget ProductCategory() {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Produk Category',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
            if (editData == null)
              GestureDetector(
                onTap: () {
                  openDialogCateory();
                },
                child: Text('Lihat semua',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
              ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        if(selectedCategory.length > 0)
          Container(
            width: size.height / 2,
            padding: new EdgeInsets.only(top: 10),
            child: Text(
              selectedCategory.length > 0
                  ? selectedCategory['name']
                  : 'Pilih Product Category',
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                fontSize: 13,
                fontFamily: 'Roboto',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
      ],
    ) ;
  }

  void openDialogCateory() async {
    var res = await Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new ProductCategoryDialogScreen.add(0, null);
    }));

    if (res != null) {
      setState(() {
        selectedProduct = {};
        selectedCategory = res;
      });
      getCategorybyId();
    }
  }

  void getCategorybyId() async {
    var category_id = selectedCategory['id'];
    var res = await Network().getData('product_categories/$category_id');
    var resultData = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        listProduct.clear();
        resultData['data']['products'].forEach((v) {
          listProduct.add(Product.fromJson(v));
        });
        products = listProduct;
        isProduct = true;
      });
    }
  }

  Widget _Product() {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(right: 20, top: 10, bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                child: Text('Produk',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                alignment: Alignment.centerLeft,
              ),
              GestureDetector(
                onTap: () {
                  productBottomSheet();
                },
                child: Text('Lihat semua',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
              )
            ],
          ),
          if (selectedProduct.length > 0)
            Container(
              width: size.height / 2,
              margin: EdgeInsets.only(top: 20),
              child: Text(
                selectedProduct.length > 0 ? selectedProduct['name'] : '',
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: 13.0,
                  fontFamily: 'Roboto',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
