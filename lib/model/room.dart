import 'package:telkom/model/location.dart';

class Room {
  late int id;
  late String name;
  late Location? location;
  Room(this.id, this.name,this.location);

  Room.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    location = (json['location'] != []
        ? Location.fromJson(json['location'])
        : []) as Location?;
  }



  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'name': name,
  //     };
}
