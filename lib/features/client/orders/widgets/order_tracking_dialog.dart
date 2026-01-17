import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avvento/core/enums/order_status.dart';
import '../../../../core/constants/app_colors.dart';

class OrderTrackingDialog extends StatelessWidget {
  final String orderId;
  final OrderStatus status;

  const OrderTrackingDialog({
    super.key,
    required this.orderId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 48.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),

              SizedBox(height: 8.h),

              // Scrollable Content
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            Text(
                              _getStatusTitle(),
                              style: TextStyle().textColorBold(
                                fontSize: 20.sp,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'طلبك رقم #$orderId',
                              style: TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Animation Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _buildAnimationSection(context),
                      ),

                      SizedBox(height: 24.h),

                      // Timeline
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _buildTimeline(context),
                      ),

                      SizedBox(height: 24.h),

                      // Driver Info (if applicable)
                      if (status == OrderStatus.onTheWay ||
                          status == OrderStatus.awaitingDelivery)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: _buildDriverInfo(context),
                        ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusTitle() {
    return status.label;
  }

  Widget _buildAnimationSection(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        image: status == OrderStatus.preparing || status == OrderStatus.onTheWay
            ? DecorationImage(
                image: AssetImage('assets/images/orders/order_tracking_bg.png'),
                fit: BoxFit.cover,
                opacity: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0,
              )
            : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
      ),
      child: _getAnimationWidget(context),
    );
  }

  Widget _getAnimationWidget(BuildContext context) {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3.w),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ننتظر رد المطعم...',
                style: TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        );

      case OrderStatus.confirmed:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Color(0xFF00C950),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.check, color: Colors.white, size: 40.sp),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'تم القبول!',
                  style: TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.preparing:
        return Center(
          child: Text('🥩', style: TextStyle(fontSize: 60.sp)),
        );

      case OrderStatus.onTheWay:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('🛵', style: TextStyle(fontSize: 60.sp)),

              Container(
                width: double.infinity,
                height: 40.h,
                decoration: ShapeDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                    side: BorderSide(
                      width: 0.76,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.awaitingDelivery:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🏠', style: TextStyle(fontSize: 60.sp)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'الكابتن أفينتو بالخارج...',
                  style: TextStyle().textColorBold(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.delivered:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('😋', style: TextStyle(fontSize: 72.sp)),
              SizedBox(height: 8.h),
              Text(
                'بالهناء والشفاء!',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'نتمنى لك وجبة لذيذة',
                style: TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        );
      case OrderStatus.cancelled:
        // TODO: Handle this case.
        return Center(
          child: Text('تم الغاء الطلب', style: TextStyle(fontSize: 30.sp)),
        );
    }
  }

  Widget _buildTimeline(BuildContext context) {
    return Container(
      // height: 360.h,
      child: Stack(
        children: [
          // Vertical Line
          PositionedDirectional(
            start: 20.w,
            top: 12.h,
            child: Container(
              width: 2.w,
              height: 312.h,
              color: Theme.of(context).dividerColor,
            ),
          ),

          // Timeline Items
          Column(
            children: [
              _buildTimelineItem(
                context,
                time: '12:30',
                title: 'بانتظار قبول المطعم',
                isActive: status.index >= 0,
                isCurrent: status == OrderStatus.pendingRestaurant,
                icon: "assets/svg/client/orders/pending_acceptance.svg",
              ),

              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:31',
                title: 'تم تأكيد الطلب',
                isActive: status.index >= 1,
                isCurrent: status == OrderStatus.confirmed,
                icon: "assets/svg/client/orders/confirmed.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:35',
                title: 'جاري التحضير',
                isActive: status.index >= 2,
                isCurrent: status == OrderStatus.preparing,
                icon: "assets/svg/client/orders/preparing.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:50',
                title: 'في الطريق إليك',
                isActive: status.index >= 3,
                isCurrent: status == OrderStatus.onTheWay,
                icon: "assets/svg/client/orders/on_the_way.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '01:05',
                title: 'في انتظار الاستلام',
                isActive: status.index >= 4,
                isCurrent: status == OrderStatus.awaitingDelivery,
                icon: "assets/svg/client/orders/waiting_pickup.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '01:10',
                title: 'تم تسليم الطلب',
                isActive: status.index >= 5,
                isCurrent: status == OrderStatus.delivered,
                icon: "assets/svg/client/orders/delivered.svg",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String time,
    required String title,
    required bool isActive,
    required bool isCurrent,
    required String icon,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: isCurrent ? 44.w : 40.w,
          height: isCurrent ? 44.h : 40.h,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary
                : (isActive ? Color(0xFF00C950) : Theme.of(context).cardColor),
            shape: BoxShape.circle,
            border: isActive && !isCurrent
                ? Border.all(color: Color(0xFF00C950), width: 1.5.w)
                : (isCurrent
                      ? Border.all(color: Theme.of(context).dividerColor, width: 1.5.w)
                      : Border.all(color: Theme.of(context).dividerColor, width: 1.5.w)),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: SvgIcon(
              iconName: icon,
              color: isCurrent
                  ? Colors.white
                  : (isActive ? Colors.white : Theme.of(context).dividerColor),
              height: isCurrent ? 18.sp : 16.sp,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Title
        Expanded(
          child: Text(
            title,
            style: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: isCurrent
                  ? Theme.of(context).textTheme.titleLarge?.color
                  : (isActive
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3)),
            ),
          ),
        ),
        // Time
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            time,
            style: TextStyle().textColorBold(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildDriverInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Action Buttons
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Color(0xFFFF4500),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // Driver Info
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محمد علي',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'كيا سيراتو • أبيض',
                        style: TextStyle().textColorNormal(
                          fontSize: 10.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
    );
  }

  static void show(BuildContext context, String orderId, OrderStatus status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: OrderTrackingDialog(orderId: orderId, status: status),
      ),
    );
  }
}
