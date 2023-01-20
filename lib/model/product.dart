import 'package:telkom/model/asset.dart';
import 'package:telkom/model/asset_two.dart';
import 'package:telkom/model/product_category.dart';
import 'package:telkom/model/product_include.dart';
import 'package:telkom/model/product_price.dart';

class Product {
  late int id,has_room,has_asset_type,has_product_prices,has_term,has_stock,price;
  late String code, name,type,term;
  late List<AssetTwo> assets;
  late List<ProductCategories> productCategories;
  late List<ProductIncludes> productIncludes;
  late List<ProductPrices> productPrices;



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

    if (json['assets'] != null) {
      assets = List<AssetTwo>.from(
          json["assets"]
              .map((x) => AssetTwo.fromJson(x)));
      ;
    }
    if (json['product_categories']!= null) {
      productCategories = List<ProductCategories>.from(
          json["product_categories"]
              .map((x) => ProductCategories.fromJson(x)));
      ;
    }
    if (json['product_includes'] != null) {
      productIncludes = List<ProductIncludes>.from(
          json["product_includes"]
              .map((x) => ProductIncludes.fromJson(x)));
      ;
    }
    if (json['product_prices'] != null) {
      productPrices = List<ProductPrices>.from(
          json["product_prices"]
              .map((x) => ProductPrices.fromJson(x)));
      ;
    }
  }




}

