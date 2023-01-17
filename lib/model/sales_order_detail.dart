import 'package:telkom/model/asset.dart';
import 'package:telkom/model/product.dart';

class SalesOrderDetail {
  late int id;
  late int?
      productId,
      assetTypeId,
      service_charge,
      tax,
      discount,
      price,
      quantity;
  late String name;
  late Asset?  asset;
  late Product? product;

  SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    assetTypeId = json['asset_type_id'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
    discount = json['discount'];
    service_charge = json['service_charge'];
    tax = json['tax'];
    // asset = (json['asset'] != null
    //     ? Asset.fromJson(json['asset'])
    //     : []) as Asset?;
    //
    // product = (json['product'] != null
    //     ? Product.fromJson(json['product'])
    //     : []) as Product?;
  }
}
