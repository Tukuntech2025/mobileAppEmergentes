class NotificationModel {
  final String notificationId;
  final String title;
  final String body;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime sentAt;
  final String? failureReason;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.sentAt,
    this.failureReason,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
      failureReason: json['failureReason']?.toString(),
    );
  }
}
