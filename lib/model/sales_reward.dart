class SalesReward {
  final int id;
  final String? type;
  final String? mode;
  final String? evidence_1;
  final String? evidenve_2;
  final int total_reward;
  final String? created_at;

  SalesReward(this.id, this.type, this.mode, this.evidence_1, this.evidenve_2,
      this.total_reward, this.created_at);

  SalesReward.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'],
        mode = json['mode'],
        evidence_1 = json['evidence_1'],
        evidenve_2 = json['evidenve_2'],
        total_reward = json['total_reward'],
        created_at = json['created_at'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'mode': mode,
        'evidence_1': evidence_1,
        'evidence_2': evidenve_2,
        'total_reward': total_reward,
        'created_at': created_at,
      };
}
