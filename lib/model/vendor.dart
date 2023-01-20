
class Vendor {
  late int id;
  late String code,name;
  Vendor(this.id, this.code,this.name);

  Vendor.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['company'] != null ? json['company']['name'] : json['person']['name'];
  }

}
