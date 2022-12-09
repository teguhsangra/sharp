class Password {
  final int tenant_id;
  final String? email;
  final String? password;
  final String? new_password;
  final String? new_password_confirmation;

  Password(this.tenant_id, this.email, this.password, this.new_password, this.new_password_confirmation);

  Password.fromJson(Map<String, dynamic> json)
      : tenant_id = json['tenant_id'],
        email = json['email'],
        password = json['password'],
        new_password = json['new_password'],
        new_password_confirmation = json['new_password_confirmation'];

  Map<String, dynamic> toJson() => {
        'tenant_id': tenant_id,
        'email': email,
        'password': password,
        'new_password': new_password,
        'new_password_confirmation': new_password_confirmation,
      };
}
