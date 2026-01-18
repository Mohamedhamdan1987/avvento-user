import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/order_model.dart';

class PreviousOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const PreviousOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final isCompleted = status == 'completed' || status == 'delivered';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.76.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.76.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Info
                Expanded(
                  child: Row(
                    children: [
                      // Restaurant Image
                      Container(
                        width: 55.w,
                        height: 55.h,
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.76.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: CachedNetworkImage(
                            imageUrl: order.restaurant.logo ?? '',
                            width: 48.w,
                            height: 48.h,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Restaurant Name and Order Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.restaurant.name,
                              style: const TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'طلب #${order.id.substring(order.id.length - 4)}',
                              style: const TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isCompleted ? AppColors.successGreen : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcon(
                        iconName: isCompleted
                            ? 'assets/svg/client/orders/check_icon.svg'
                            : 'assets/svg/client/orders/cancel_icon.svg',
                        width: 12.w,
                        height: 12.h,
                        color: isCompleted
                            ? AppColors.successGreen
                            : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isCompleted ? 'مكتمل' : 'ملغي',
                        style: const TextStyle().textColorBold(
                          fontSize: 10.sp,
                          color: isCompleted
                              ? AppColors.successGreen
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            SizedBox(height: 12.h),

            // Order Items
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'طلب يحتوي على ${order.items.length} عناصر',
                style: const TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Footer Row
            Container(
              padding: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.76.w,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    '${order.totalPrice} د.ل',
                    style: const TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),

                  // Reorder Button
                  GestureDetector(
                    onTap: () {
                      // Handle reorder
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         SvgIcon(
                          iconName: 'assets/svg/client/orders/reorder_icon.svg',
                          width: 12.w,
                          height: 12.h,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'إعادة الطلب',
                          style: const TextStyle().textColorBold(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

