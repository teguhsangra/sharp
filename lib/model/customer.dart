class Customer {
  late int id;
  late String code, name, type, email, phone, identityType,identityNumber;

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['person'] != null
        ? json['person']['name']
        : json['company']['name'];
    email = json['email'] != null ? json['email']  : '';
    phone = json['phone'] != null ? json['phone']: '';
    identityType = json['person'] != null ? json['person']['identity_type'] : 'id_cards';
    identityNumber = json['person'] != null ? json['person']['identity_number'].toString() : '';
    type = json['type'];
  }
}
