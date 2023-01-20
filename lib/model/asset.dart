
import 'package:telkom/model/location.dart';
import 'package:telkom/model/product.dart';

class Asset {
  late int id;
  late String code,name, brand;
  late Product? product;
  late Location? location;
  Asset(this.id, this.code,this.name, this.brand, this.product);

  Asset.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
    brand = json['brand'] != null ? json['brand'] : '';
    product = (json['product'] != null
        ? Product.fromJson(json['product'])
        : []) as Product?;
    location = (json['location'] != null
        ? Location.fromJson(json['location'])
        : []) as Location?;
  }



}
