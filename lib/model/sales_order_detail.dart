class SalesOrderDetail {
  late int id;
  late int?
      productId,
      assetTypeId,
      price,
      quantity;
  late String name;

  SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    assetTypeId = json['asset_type_id'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
  }
}
