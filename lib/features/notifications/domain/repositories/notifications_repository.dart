import '../entities/notification_entity.dart';

class NotificationsResponse {
  final List<NotificationEntity> notifications;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final int unreadCount;

  NotificationsResponse({
    required this.notifications,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.unreadCount,
  });
}

abstract class NotificationsRepository {
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  });
  Future<NotificationEntity> getNotificationById(String id);
  Future<int> getUnreadCount();
  Future<NotificationEntity> markAsRead(String id);
  Future<int> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<int> deleteAllNotifications();
}

