enum NotificationType {
  order,
  message,
  system,
  promotion,
  delivery,
}

enum NotificationStatus {
  unread,
  read,
}

class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationStatus status;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });
}

