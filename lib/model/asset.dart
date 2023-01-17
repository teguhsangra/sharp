
class Asset {
  late int id;
  late String code,name, brand;
  Asset(this.id, this.code,this.name, this.brand);

  Asset.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
    brand = json['brand'] != null ? json['brand'] : '';
  }



}
