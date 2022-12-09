class ChecklistResultMultipleAnswer {
  late int? id, tenantId, checklistResultContentId, isNormalAnswer;
  late String? answer;

  ChecklistResultMultipleAnswer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tenantId = json['tenant_id'];
    checklistResultContentId = json['checklist_result_content_id'];
    answer = json['answer'];
    isNormalAnswer = json['is_normal_answer'];
  }
}
