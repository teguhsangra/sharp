import 'package:telkom/model/checklist_result_content_answer_option.dart';

class ChecklistResultContent {
  late int? id,
      tenantId,
      checklistResultId,
      hasPhoto,
      isAbnormal,
      minValue,
      maxValue;
  late String? name, unit, type, answer, picturePath;
  late List<ChecklistResultContentAnswerOption> checklistResultContentAnswerOptions;

  ChecklistResultContent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tenantId = json['tenant_id'];
    checklistResultId = json['checklist_result_id'];
    name = json['name'];
    unit = json['unit'];
    type = json['type'];
    hasPhoto = json['has_photo'];
    minValue = json['min_value'];
    maxValue = json['max_value'];
    picturePath = json['picture_path'];
    answer = json['answer'];
    isAbnormal = json['is_abnormal'];
    if (json['checklist_result_content_answer_options'] != null) {
      checklistResultContentAnswerOptions =
      List<ChecklistResultContentAnswerOption>.from(json["checklist_result_content_answer_options"].map((x) => ChecklistResultContentAnswerOption.fromJson(x)));


    }
  }


}

