
class AssetType {
  late int id;
  late String code,name;
  AssetType(this.id, this.code,this.name);

  AssetType.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
  }



// Map<String, dynamic> toJson() => {
//       'id': id,
//       'name': name,
//     };
}
