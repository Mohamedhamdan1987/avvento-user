import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.drawerPurple),
        title: Text(
          'الإشعارات',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with unread count and actions
          _buildHeader(context, controller),
          
          // Filter tabs
          _buildFilterTabs(context, controller),
          
          // Notifications list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const NotificationsListShimmer();
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => controller.refreshNotifications(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64.sp,
                        color: Theme.of(context).disabledColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد إشعارات',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return AppRefreshIndicator(
                onRefresh: () => controller.refreshNotifications(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      // Load more when reaching the end
                      controller.loadNotifications();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: controller.notifications.length + (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.notifications.length) {
                        // Load more indicator
                        if (controller.isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final notification = controller.notifications[index];
                      return _buildNotificationCard(context, controller, notification);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationsController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() => Text(
                      '${controller.unreadCount.value} غير مقروء',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    )),
              ],
            ),
          ),
          Obx(() => controller.unreadCount.value > 0
              ? TextButton.icon(
                  onPressed: () => controller.markAllAsRead(),
                  icon: const Icon(Icons.done_all),
                  label: const Text('قراءة الكل'),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, NotificationsController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'الكل',
            isSelected: controller.selectedStatus == null,
            onTap: () => controller.filterByStatus(null),
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            context,
            label: 'غير مقروء',
            isSelected: controller.selectedStatus == 'unread',
            onTap: () => controller.filterByStatus('unread'),
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            context,
            label: 'مقروء',
            isSelected: controller.selectedStatus == 'read',
            onTap: () => controller.filterByStatus('read'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.drawerPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected ? null : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationsController controller,
    NotificationEntity notification,
  ) {
    final isUnread = notification.status == NotificationStatus.unread;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isUnread ? AppColors.drawerPurple : Theme.of(context).dividerColor,
          width: isUnread ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (isUnread) {
            controller.markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on type
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              color: AppColors.drawerPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          controller.getNotificationTypeLabel(notification.type),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDate(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 20.sp,
                          color: AppColors.error,
                          onPressed: () => controller.deleteNotification(notification.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.message:
        return Colors.green;
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.delivery:
        return Colors.purple;
      case NotificationType.system:
        return AppColors.drawerPurple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.receipt_long;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.delivery:
        return Icons.delivery_dining;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

