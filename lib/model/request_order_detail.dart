class RequestOrderDetail {
  late int id;
  late int? productId, price, quantity;
  late String name;

  RequestOrderDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
  }
}
