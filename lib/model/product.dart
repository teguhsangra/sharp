
class Product {
  late int
      id,
      hasAssetType,
      hasRoom,
      hasProductPrice,
      hasTerm,
      hasStock
  ;
  late String code,name,
      term;
  late num price;
  Product(
      this.id,
      this.code,
      this.name,
      this.price,
      this.hasAssetType,
      this.hasRoom,
      this.hasProductPrice,
      this.hasTerm,
      this.hasStock,
      this.term
      );

  Product.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    name = json['name'];
    price = json['price'] != null || json['price'] != 0 ? json['price'] : 0;
    hasAssetType = json['has_asset_type'];
    hasRoom = json['has_room'];
    hasProductPrice = json['has_product_prices'];
    hasTerm = json['has_term'];
    hasStock = json['has_stock'];
    term = json['term'];
  }



// Map<String, dynamic> toJson() => {
//       'id': id,
//       'name': name,
//     };
}
