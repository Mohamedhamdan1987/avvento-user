import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/api_exception.dart';
import '../models/notification_model.dart';

class NotificationsResponse {
  final List<NotificationModel> notifications;
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

abstract class NotificationsRemoteDataSource {
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  });
  Future<NotificationModel> getNotificationById(String id);
  Future<int> getUnreadCount();
  Future<NotificationModel> markAsRead(String id);
  Future<int> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<int> deleteAllNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final DioClient dioClient;

  NotificationsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      final response = await dioClient.get(
        'notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final notifications = (data['notifications'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        final pagination = data['pagination'] ?? {};

        return NotificationsResponse(
          notifications: notifications,
          total: pagination['total'] ?? 0,
          page: pagination['page'] ?? page,
          limit: pagination['limit'] ?? limit,
          totalPages: pagination['totalPages'] ?? 0,
          unreadCount: pagination['unreadCount'] ?? 0,
        );
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      final response = await dioClient.get('notifications/$id');

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch notification');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.get('notifications/unread-count');

      if (response.statusCode == 200) {
        // Handle both direct number response and object response
        if (response.data is int) {
          return response.data;
        } else if (response.data is Map) {
          return response.data['unreadCount'] ?? response.data['count'] ?? 0;
        }
        return 0;
      } else {
        throw Exception('Failed to fetch unread count');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to fetch unread count: $e');
    }
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    try {
      final response = await dioClient.patch('notifications/$id/read');

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final response = await dioClient.patch('notifications/read-all');

      if (response.statusCode == 200) {
        return response.data['updated'] ?? 0;
      } else {
        throw Exception('Failed to mark all as read');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final response = await dioClient.delete('notifications/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<int> deleteAllNotifications() async {
    try {
      final response = await dioClient.delete('notifications');

      if (response.statusCode == 200) {
        return response.data['deleted'] ?? 0;
      } else {
        throw Exception('Failed to delete all notifications');
      }
    } on DioException catch (e) {
      throw ApiException.handleException(e);
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }
}

