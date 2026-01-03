import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreviousOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTap;

  const PreviousOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final isCompleted = status == 'completed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.76.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Color(0xFFF3F4F6),
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
                          color: Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Color(0xFFF3F4F6),
                            width: 0.76.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: CachedNetworkImage(
                            imageUrl: order['restaurantImage'] ?? '',
                            width: 48.w,
                            height: 48.h,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Color(0xFFF9FAFB),
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
                              order['restaurantName'] ?? '',
                              style: TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: Color(0xFF101828),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'طلب #${order['id']}',
                              style: TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Color(0xFF99A1AF),
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
                      color: isCompleted
                          ? Color(0xFFF0FDF4)
                          : Color(0xFFFEF2F2),
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
                              ? Color(0xFF00A63E)
                              : Color(0xFFE7000B),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isCompleted ? 'مكتمل' : 'ملغي',
                          style: TextStyle().textColorBold(
                            fontSize: 10.sp,
                            color: isCompleted
                                ? Color(0xFF00A63E)
                                : Color(0xFFE7000B),
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                order['items'] ?? '',
                style: TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Color(0xFF6A7282),
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
                    color: Color(0xFFF9FAFB),
                    width: 0.76.w,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    '${order['price']} د.ل',
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Color(0xFF101828),
                    ),
                  ),

                  // Reorder Button (only for previous orders)
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
                            color: Color(0xFF7F22FE),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'إعادة الطلب',
                            style: TextStyle().textColorBold(
                              fontSize: 12.sp,
                              color: Color(0xFF7F22FE),
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

