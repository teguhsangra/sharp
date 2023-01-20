
import 'package:telkom/model/location.dart';
import 'package:telkom/model/product.dart';

class AssetTwo {
  late int id;
  late String code,name, brand;
  AssetTwo(this.id, this.code,this.name, this.brand);

  AssetTwo.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
    brand = json['brand'] != null ? json['brand'] : '';
  }



}
