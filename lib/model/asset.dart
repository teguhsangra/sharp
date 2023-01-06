
class Asset {
  late int id;
  late String code,name;
  Asset(this.id, this.code,this.name);

  Asset.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
  }



}
