import 'package:telkom/model/product_category.dart';
import 'package:telkom/model/product_include.dart';
import 'package:telkom/model/product_price.dart';

class PrimaryProduct {
  late int id,has_room,has_asset_type,has_product_prices,has_term,has_stock,price;
  late String code, name,type,term;

  PrimaryProduct({
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

  PrimaryProduct.fromJson(Map<String, dynamic> json) {
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


  }
}