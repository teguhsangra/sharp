class Location {
  late int id;
  late String code, name, country, city, address, timezone;
  late double latitude, longitude;

  Location({
    required this.id,
    required this.code,
    required this.name,
  });

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    country = json['country'];
    city = json['city'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    timezone = json['timezone'];
  }
}
