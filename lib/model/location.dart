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
    country = json['country'] != null ? json['country'] : '';
    city = json['city'] != null  ? json['city'] : '';
    address = json['address'];
    latitude = json['latitude'] != null ? json['latitude'] : 0;
    longitude = json['longitude'] != null ? json['longitude'] : 0;
    timezone = json['timezone'];
  }
}
