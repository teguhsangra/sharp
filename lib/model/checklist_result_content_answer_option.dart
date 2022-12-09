class ChecklistResultContentAnswerOption {
  ChecklistResultContentAnswerOption({
    this.id,
    this.tenantId,
    this.checklistResultContentId,
    this.name,
    this.isNormalAnswer,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  int? tenantId;
  int? checklistResultContentId;
  String? name;
  int? isNormalAnswer;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory ChecklistResultContentAnswerOption.fromJson(Map<String, dynamic> json) => ChecklistResultContentAnswerOption(
    id: json["id"],
    tenantId: json["tenant_id"],
    checklistResultContentId: json["checklist_result_content_id"],
    name: json["name"],
    isNormalAnswer: json["is_normal_answer"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tenant_id": tenantId,
    "checklist_result_content_id": checklistResultContentId,
    "name": name,
    "is_normal_answer": isNormalAnswer,
    "created_at": createdAt.toString(),
    "updated_at": updatedAt.toString(),
  };
}