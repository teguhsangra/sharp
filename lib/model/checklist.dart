class Checklist {
  late int id;
  late String code, name, period;

  Checklist(
      {required this.id,
        required this.code,
        required this.name,
        required this.period});

  Checklist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    period = json['period'];
  }
}