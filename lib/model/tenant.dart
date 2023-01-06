class Tenant {
  late int id;
  late String code;
  late String name;
  late String phone;
  late String email;
  late String headOfficeAddress;

  Tenant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    headOfficeAddress = json['head_office_address'];
  }
}

