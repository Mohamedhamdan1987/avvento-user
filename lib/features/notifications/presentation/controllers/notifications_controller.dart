import 'package:get/get.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository repository;

  NotificationsController(this.repository);

  // Observable state
  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Pagination
  int currentPage = 1;
  final int pageSize = 20;
  bool hasMore = true;
  bool isLoadingMore = false;

  // Filters
  String? selectedType;
  String? selectedStatus;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 1;
        hasMore = true;
        notifications.clear();
        isLoading.value = true;
      }

      if (!hasMore || isLoadingMore) return;

      isLoadingMore = true;
      errorMessage.value = '';

      final response = await repository.getNotifications(
        page: currentPage,
        limit: pageSize,
        type: selectedType,
        status: selectedStatus,
      );

      if (refresh) {
        notifications.value = response.notifications;
      } else {
        notifications.addAll(response.notifications);
      }

      hasMore = currentPage < response.totalPages;
      currentPage++;
      unreadCount.value = response.unreadCount;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingMore = false;
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await repository.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      // Silently fail for unread count
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await repository.markAsRead(notificationId);
      
      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = notifications[index];
        notifications[index] = NotificationEntity(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          status: NotificationStatus.read,
          data: notification.data,
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
          isDeleted: notification.isDeleted,
        );
      }
      
      // Update unread count
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await repository.markAllAsRead();
      
      // Update all notifications to read
      notifications.value = notifications.map((n) {
        if (n.status == NotificationStatus.unread) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            title: n.title,
            body: n.body,
            type: n.type,
            status: NotificationStatus.read,
            data: n.data,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
            updatedAt: DateTime.now(),
            isDeleted: n.isDeleted,
          );
        }
        return n;
      }).toList();

      unreadCount.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await repository.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      
      // Update unread count if needed
      final deleted = notifications.firstWhereOrNull((n) => n.id == notificationId);
      if (deleted != null && deleted.status == NotificationStatus.unread) {
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await repository.deleteAllNotifications();
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByType(String? type) {
    selectedType = type;
    loadNotifications(refresh: true);
  }

  void filterByStatus(String? status) {
    selectedStatus = status;
    loadNotifications(refresh: true);
  }

  void clearFilters() {
    selectedType = null;
    selectedStatus = null;
    loadNotifications(refresh: true);
  }

  String getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return 'طلب';
      case NotificationType.message:
        return 'رسالة';
      case NotificationType.promotion:
        return 'عرض';
      case NotificationType.delivery:
        return 'تسليم';
      case NotificationType.system:
        return 'نظام';
    }
  }
}

