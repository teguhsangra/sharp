import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/dialog_sales_order_detail.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/product_category.dart';
import 'package:telkom/network/api.dart';

class ProductCategoryDialogScreen extends StatefulWidget {
  int count;
  var product_category_id;

  ProductCategoryDialogScreen.add(this.count,this.product_category_id);

  ProductCategoryDialogScreen.edit(this.count,this.product_category_id);

  @override
  ProductCategoryDialogState createState() {
    if(this.product_category_id != null){
      return new ProductCategoryDialogState(this.count,this.product_category_id);
    }else{
      return new ProductCategoryDialogState(0,null);
    }

  }
}

class ProductCategoryDialogState extends State<ProductCategoryDialogScreen> {
  bool isLoading = false;
  bool isChild = false;
  var user = {};
  final form = GlobalKey<FormState>();


  late List listCategory = <ProductCategories>[];
  List category = <ProductCategories>[];
  var product_category_id;
  var category_name;
  int page =0;
  int count = 0;
  ProductCategoryDialogState(this.count,this.product_category_id);

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
    if(product_category_id == null){
      getProductCategories();
      category = listCategory;
    }else{
      getCategorybyId();
      category = listCategory;
    }

  }




  void getProductCategories() async {
    var tenant_id = user['tenant_id'];
    var res = await Network().getData('product_categories?is_parent=Y&tenant_id=$tenant_id');
    var resultData = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
    setState(() {
      isChild = true;
      listCategory.clear();
      resultData['data'].forEach((v) {
        listCategory.add(ProductCategories.fromJson(v));
      });
    });
    }
  }

  void getCategorybyId() async {

    var res = await Network().getData('product_categories/$product_category_id');
    var resultData = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        listCategory.clear();
        if(resultData['data']['this_child'].length != []){
          isChild = true;
          resultData['data']['this_child'].forEach((v) {
            listCategory.add(ProductCategories.fromJson(v));
          });

        }else{

        }

      });
    }
  }


  void openDialogCateory() async{
    var selected_category = {'id': product_category_id, 'name': category_name};
    var res = await Network().getData('product_categories/$product_category_id');
    var resultData = jsonDecode(res.body);

   if(resultData['data']['this_child'].length > 0 ){
     Navigator.of(context).push(new MaterialPageRoute(
         builder: (BuildContext context) {
           return new ProductCategoryDialogScreen.edit(count+1,product_category_id);
         }));
   }else{
    Navigator.of(context).popUntil((_) => page++ >= count);
    Navigator.of(context).pop(selected_category);


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
          "Kategory Produk",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: category.length,
              itemBuilder: (context, index) {
                var item = category[index];
                return CheckboxListTile(
                  title: Text(category[index].name),
                  value: product_category_id == item.id ? true : false,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        product_category_id = item.id;
                        category_name = item.name;
                        openDialogCateory();

                      } else {
                        product_category_id = null;
                      }
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

}