class Profile {
  final int id;
  final int tenant_id;
  final String? code;
  final String? email;
  final String? name;
  final String? phone;
  final String? city;
  final String? country;
  final String? identity_type;
  final String? identity_number;
  final String? address;

  Profile(this.id, this.tenant_id, this.code, this.email, this.name, this.phone, this.city, this.country,
      this.identity_type, this.identity_number, this.address);

  Profile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tenant_id = json['tenant_id'],
        code = json['code'],
        email = json['email'],
        name = json['name'],
        phone = json['phone'],
        city = json['city'],
        country = json['country'],
        identity_type = json['identity_type'],
        identity_number = json['identity_number'],
        address = json['address'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id':tenant_id,
        'code':code,
        'email':email,
        'name': name,
        'phone': phone,
        'city': city,
        'country': country,
        'identity_type': identity_type,
        'identity_number': identity_number,
        'address': address,
      };
}
