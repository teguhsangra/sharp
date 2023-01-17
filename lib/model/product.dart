import 'package:telkom/model/product_category.dart';
import 'package:telkom/model/product_include.dart';
import 'package:telkom/model/product_price.dart';

class Product {
  late int id,has_room,has_asset_type,has_product_prices,has_term,has_stock,price;
  late String code, name,type,term;
  // late List<ProductCategories> productCategories;
  // late List<ProductIncludes> productIncludes;
  // late List<ProductPrices> productPrices;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.has_room,
    required this.has_asset_type,
    required this.has_product_prices,
    required this.has_term,
    required this.has_stock,
    required this.type,
    required this.term,
    required this.price,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    has_room = json['has_room'];
    has_asset_type = json['has_asset_type'];
    has_product_prices = json['has_product_prices'];
    has_term = json['has_term'];
    has_stock = json['has_stock'];
    type = json['type'];
    term = json['term'];
    price = json['price'];

    // if (json['product_categories'].length > 0) {
    //   productCategories = List<ProductCategories>.from(
    //       json["product_categories"]
    //           .map((x) => ProductCategories.fromJson(x)));
    //   ;
    // }
    // if (json['product_includes'].length > 0) {
    //   productIncludes = List<ProductIncludes>.from(
    //       json["product_includes"]
    //           .map((x) => ProductIncludes.fromJson(x)));
    //   ;
    // }
    // if (json['product_prices'].length > 0) {
    //   productPrices = List<ProductPrices>.from(
    //       json["product_prices"]
    //           .map((x) => ProductPrices.fromJson(x)));
    //   ;
    // }
  }
}