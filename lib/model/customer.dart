class Customer {
  late int id;
  late String code, name, type;

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['person'] != null
        ? json['person']['name']
        : json['company']['name'];
    type = json['type'];
  }
}
