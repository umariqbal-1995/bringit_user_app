class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['_id'] ?? json['id'] ?? '',
        title: json['title'] ?? '',
        message: json['message'] ?? json['body'] ?? '',
        isRead: json['read'] ?? json['isRead'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        type: json['type'],
      );
}
