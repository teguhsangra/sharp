
import 'package:telkom/model/location.dart';
import 'package:telkom/model/product.dart';

class Asset {
  late int id;
  late String code,name, brand;
  late Product? product;
  late Location? location;

  Asset.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
    brand = json['brand'] != null ? json['brand'] : '';
    if(json['product'] != null){
      product = ( json['product'] != null ? Product.fromJson(json['product'])
          : []) as Product?;
    }
    if(json['location'] != null){
      location = (json['location'] != null
          ? Location.fromJson(json['location'])
          : []) as Location?;
    }


  }



}
