class ProductCategories {
  late int? id,tenantId;
  late String? code,name;
  ProductCategories(this.id, this.tenantId,this.code,this.name);

  ProductCategories.fromJson(Map<String, dynamic> json){
    id = json['id'];
    tenantId = json['tenant_id'];
    code = json['code'];
    name = json['name'];
  }
}
