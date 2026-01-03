import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    required super.status,
    super.data,
    super.readAt,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle populated user field
    String userId;
    if (json['user'] is Map) {
      userId = json['user']['_id'] ?? json['user']['id'] ?? '';
    } else {
      userId = json['user']?.toString() ?? '';
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseNotificationType(json['type'] ?? 'system'),
      status: _parseNotificationStatus(json['status'] ?? 'unread'),
      data: json['data'] as Map<String, dynamic>?,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'title': title,
      'body': body,
      'type': _notificationTypeToString(type),
      'status': _notificationStatusToString(status),
      'data': data,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return NotificationType.order;
      case 'message':
        return NotificationType.message;
      case 'promotion':
        return NotificationType.promotion;
      case 'delivery':
        return NotificationType.delivery;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  static NotificationStatus _parseNotificationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'read':
        return NotificationStatus.read;
      case 'unread':
      default:
        return NotificationStatus.unread;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return 'order';
      case NotificationType.message:
        return 'message';
      case NotificationType.promotion:
        return 'promotion';
      case NotificationType.delivery:
        return 'delivery';
      case NotificationType.system:
        return 'system';
    }
  }

  static String _notificationStatusToString(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.read:
        return 'read';
      case NotificationStatus.unread:
        return 'unread';
    }
  }
}

