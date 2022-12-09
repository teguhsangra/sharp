class NotificationData {
  final int id;
  final String? title;
  final String? message;
  final String? link;
  final String? source;
  final int is_read;
  final String? created_at;

  NotificationData(this.id, this.title, this.message, this.link, this.source,
      this.is_read, this.created_at);

  NotificationData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        message = json['message'],
        link = json['link'],
        source = json['source'],
        is_read = json['is_read'],
        created_at = json['created_at'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'link': link,
        'source': source,
        'is_read': is_read,
        'created_at': created_at,
      };
}
