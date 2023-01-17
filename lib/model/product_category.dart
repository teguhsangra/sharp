import 'package:telkom/model/product.dart';

class ProductCategories {
  late int? id,tenantId;
  late String? code,name;
  late List<Product> products;

  ProductCategories(this.id, this.tenantId,this.code,this.name);

  ProductCategories.fromJson(Map<String, dynamic> json){
    id = json['id'];
    tenantId = json['tenant_id'];
    code = json['code'];
    name = json['name'];
    if (json['products'] != null) {
      products = List<Product>.from(
          json["products"]
              .map((x) => Product.fromJson(x)));
      ;
    }

  }
}
