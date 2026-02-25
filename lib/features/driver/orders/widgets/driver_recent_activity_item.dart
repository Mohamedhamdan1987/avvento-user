import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/models/driver_order_model.dart';

class DriverRecentActivityItem extends StatelessWidget {
  final DriverOrderModel order;

  const DriverRecentActivityItem({
    super.key,
    required this.order,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy', 'ar').format(dateTime);
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return const Color(0xFF00A63E);
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.onTheWay:
      case OrderStatus.deliveryReceived:
        return const Color(0xFF2563EB);
      case OrderStatus.preparing:
      case OrderStatus.awaitingDelivery:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return const Color(0xFFF0FDF4);
      case OrderStatus.cancelled:
        return const Color(0xFFFEF2F2);
      case OrderStatus.onTheWay:
      case OrderStatus.deliveryReceived:
        return const Color(0xFFEFF6FF);
      case OrderStatus.preparing:
      case OrderStatus.awaitingDelivery:
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = order.status.label;
    final fgColor = _statusColor(order.status);
    final bgColor = _statusBgColor(order.status);
    final displayPrice = order.deliveryFee ?? order.totalAmount;

    return Container(
      padding: EdgeInsetsDirectional.all(16.76.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Center(
              child: Text(
                order.orderNumber,
                style: const TextStyle().textColorBold(
                  fontSize: 10.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurantName,
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_getTimeAgo(order.createdAt)} • ${order.customerName}',
                  style: const TextStyle().textColorNormal(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF99A1AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${displayPrice.toStringAsFixed(2)} د.ل',
                style: const TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle().textColorNormal(
                    fontSize: 10.sp,
                    color: fgColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}