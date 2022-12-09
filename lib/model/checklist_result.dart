import 'package:telkom/model/checklist.dart';
import 'package:telkom/model/checklist_result_content.dart';
import 'package:telkom/model/room.dart';
import 'package:telkom/model/location.dart';

class ChecklistResult {
  late int id, isChecked, hasAbnormalAnswer, isOverdue, tenantId;
  late int? assetId, customerId, employeeId, roomId, locationId;
  late String? allotment, period, timezone;
  late Checklist? checklist;
  late List<ChecklistResultContent> checklistResultContents;
  late Location? location;
  late Room? room;
  late DateTime? startedAt, endedAt, filledAt;

  ChecklistResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tenantId = json['tenant_id'];
    assetId = json['asset_id'];
    customerId = json['customer_id'];
    employeeId = json['employee_id'];
    roomId = json['room_id'];
    locationId = json['location_id'];
    hasAbnormalAnswer = json['has_abnormal_answer'];
    isOverdue = json['is_overdue'];
    allotment = json['allotment'];
    period = json['period'];
    startedAt = DateTime.parse(json['started_at'])!;
    endedAt = DateTime.parse(json['ended_at'])!;
    filledAt = json['filled_at'] == null ?DateTime.now() : DateTime.parse(json['filled_at']);
    timezone = json['timezone'];
    room = (json['room'] != [] ? Room.fromJson(json['room']) : []) as Room?;
    location = (json['location'] != []
        ? Location.fromJson(json['location'])
        : []) as Location?;
    checklist = (json['checklist'] != []
        ? Checklist.fromJson(json['checklist'])
        : []) as Checklist?;

    if (json['checklist_result_contents'] != null) {
      checklistResultContents = List<ChecklistResultContent>.from(
          json["checklist_result_contents"]
              .map((x) => ChecklistResultContent.fromJson(x)));
      ;
    }

  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "isChecked": isChecked,
    "hasAbnormalAnswer": hasAbnormalAnswer,
    "isOverdue": isOverdue,
    "allotment": allotment,
    "period": period,
    "timezone": timezone,
    "room": room,
    "location": location,
    "checklist": checklist,
    "checklistResultContents": checklistResultContents
  };
}