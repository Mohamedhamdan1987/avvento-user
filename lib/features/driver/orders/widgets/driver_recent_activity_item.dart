import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(16.76.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
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

          // Order number badge (on the left in RTL)
          Container(
            width: 50.w,
            height: 50.h,
            // padding: EdgeInsetsDirectional.symmetric(
            //   horizontal: 8.w,
            //   vertical: 2.h,
            // ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Center(
              child: Text(
                '#${order.orderNumber}',
                style: const TextStyle().textColorBold(
                  fontSize: 10.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),


          // Middle: Restaurant info and order number
          Expanded(
            child: Row(
              children: [
                // Restaurant info (on the right in RTL)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${_getTimeAgo(order.createdAt)} • مكتمل',
                        style: const TextStyle().textColorNormal(
                          fontSize: 12.sp,
                          color: const Color(0xFF99A1AF),
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Left side: Price and Status (in RTL, left = end)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${order.totalAmount.toStringAsFixed(2)} د.ل',
                style: const TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  'ناجح',
                  style: const TextStyle().textColorNormal(
                    fontSize: 10.sp,
                    color: const Color(0xFF00A63E),
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