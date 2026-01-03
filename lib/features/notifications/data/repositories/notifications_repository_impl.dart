import '../../domain/repositories/notifications_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../datasources/notifications_remote_datasource.dart' as datasource;

class NotificationsRepositoryImpl implements NotificationsRepository {
  final datasource.NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    final response = await remoteDataSource.getNotifications(
      page: page,
      limit: limit,
      type: type,
      status: status,
    );

    return NotificationsResponse(
      notifications: response.notifications,
      total: response.total,
      page: response.page,
      limit: response.limit,
      totalPages: response.totalPages,
      unreadCount: response.unreadCount,
    );
  }





  @override
  Future<NotificationEntity> getNotificationById(String id) async {
    return await remoteDataSource.getNotificationById(id);
  }

  @override
  Future<int> getUnreadCount() async {
    return await remoteDataSource.getUnreadCount();
  }

  @override
  Future<NotificationEntity> markAsRead(String id) async {
    return await remoteDataSource.markAsRead(id);
  }

  @override
  Future<int> markAllAsRead() async {
    return await remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String id) async {
    return await remoteDataSource.deleteNotification(id);
  }

  @override
  Future<int> deleteAllNotifications() async {
    return await remoteDataSource.deleteAllNotifications();
  }
}

