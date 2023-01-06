class ProductPrices {
  late int?
      id,
      tenantId,
      productId,
      assetTypeId,
      roomId,
      hasQuantity,
      hasTerm,
      hasComplimentary,
      defaultQuantity,
      price;
  late String? name, term,item;
  ProductPrices(
      this.id,
      this.tenantId,
      this.productId,
      this.name,
      this.assetTypeId,
      this.roomId,
      this.hasQuantity,
      this.term,
      this.item,
      this.price,
      this.defaultQuantity
      );

  ProductPrices.fromJson(Map<String, dynamic> json){
    id = json['id'];
    tenantId = json['tenant_id'];
    productId = json['product_id'];
    name = json['name'];
    assetTypeId = json['asset_type_id'];
    roomId = json['room_id'];
    hasQuantity = json['has_quantity'];
    term = json['term'];
    item = json['item'];
    price = json['price'];
    defaultQuantity = json['defaultQuantity'];

  }
}
