import 'package:avvento/features/driver/home/models/driver_order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DriverOrderCard extends StatelessWidget {
  final DriverOrderModel order;
  final VoidCallback? onTap;

  const DriverOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.borderGray.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order.orderNumber}',
                  style: const TextStyle().textColorBold(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Restaurant name
            Row(
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 18.r,
                  color: AppColors.textMedium,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.restaurantName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Customer name
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18.r,
                  color: AppColors.textMedium,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Delivery address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.r,
                  color: AppColors.textMedium,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.deliveryLocation.address,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Divider
            Divider(color: AppColors.borderGray.withOpacity(0.3)),
            SizedBox(height: 12.h),

            // Bottom row with price and items count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${order.items.length} عنصر',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${order.totalAmount.toStringAsFixed(2)} د.ل',
                  style: const TextStyle().textColorBold(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textMedium;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'تم القبول';
      case 'picked_up':
        return 'تم الاستلام';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
