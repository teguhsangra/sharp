import 'package:telkom/model/customer.dart';
import 'package:telkom/model/room.dart';
import 'package:telkom/model/request_order_detail.dart';

class RequestOrder {
  late int id;
  late int? roomId, customerId, employeeId,totalPrice;
  late String code, name, status, followUpAt;
  late String? remarks, evidence1, evidence2, rejectReason, timeZone;
  late Room? room;
  late Customer? customer;
  late List<RequestOrderDetail> requestOrderDetails;
  late DateTime? createdAt;
  late String? followUpBy, followUpNotes, followUpPicture;

  RequestOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['room_id'];
    customerId = json['customer_id'];
    employeeId = json['employee_id'];
    code = json['code'];
    name = json['name'];
    remarks = json['remarks'];
    evidence1 = json['evidence_1'];
    evidence2 = json['evidence_2'];
    status = json['status'];
    rejectReason = json['reject_reason'] != null ? json['reject_reason'] : '';
    totalPrice = json['total_price'];
    createdAt = DateTime.parse(json['created_at']);
    followUpAt = json['follow_up_at'] != null  ? json['follow_up_at'] : '';
    followUpBy = json['follow_up_by'];
    followUpNotes = json['follow_up_notes'];
    followUpPicture = json['follow_up_picture'];
    timeZone = json['timezone'];
    room = (json['room'] != []
        ? Room.fromJson(json['room'])
        : []) as Room?;
    customer = (json['customer'] != []
        ? Customer.fromJson(json['customer'])
        : []) as Customer?;

    if (json['request_order_details'] != null) {
      requestOrderDetails = List<RequestOrderDetail>.from(
          json["request_order_details"]
              .map((detailData) => RequestOrderDetail.fromJson(detailData)));
      ;
    }
  }
}
