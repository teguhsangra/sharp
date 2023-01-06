class ProductIncludes {
  late int?id,
      tenantId,
      productId,
      assetTypeId,
      roomId,
      otherProductId,
      isCalculateToOrder,
      hasTax,
      hasServiceCharge,
      quantity,
      price,
      cost;
  late String? name;

  ProductIncludes(
      this.id,
      this.tenantId,
      this.name,
      this.assetTypeId,
      this.roomId,
      this.otherProductId,
      this.price,
      this.cost,
      this.quantity,
      this.isCalculateToOrder,
      this.hasTax,
      this.hasServiceCharge
      );

  ProductIncludes.fromJson(Map<String, dynamic> json){
    id = json['id'];
    tenantId = json['tenant_id'];
    name = json['name'];
    assetTypeId = json['asset_type_id'];
    roomId = json['room_id'];
    otherProductId = json['other_product_id'];
    price = json['price'];
    cost = json['cost'];
    quantity = json['quantity'];
    isCalculateToOrder = json['is_calculated_to_order'];
    hasTax = json['has_tax'];
    hasServiceCharge = json['has_service_charge'];
  }
}
