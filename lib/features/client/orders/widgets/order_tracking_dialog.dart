import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum OrderStatus {
  pendingAcceptance, // بانتظار قبول المطعم
  confirmed, // تم تأكيد الطلب
  preparing, // جاري التحضير
  onTheWay, // في الطريق إليك
  waitingPickup, // في انتظار الاستلام
  delivered, // تم تسليم الطلب
}

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
        color: Colors.white,
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
                  color: Color(0xFFE5E7EB),
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
                                color: Color(0xFF101828),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'طلبك رقم #$orderId',
                              style: TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Color(0xFF6A7282),
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
                        child: _buildAnimationSection(),
                      ),

                      SizedBox(height: 24.h),

                      // Timeline
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _buildTimeline(),
                      ),

                      SizedBox(height: 24.h),

                      // Driver Info (if applicable)
                      if (status == OrderStatus.onTheWay ||
                          status == OrderStatus.waitingPickup)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: _buildDriverInfo(),
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
    switch (status) {
      case OrderStatus.pendingAcceptance:
        return 'بانتظار قبول المطعم';
      case OrderStatus.confirmed:
        return 'تم تأكيد الطلب';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.onTheWay:
        return 'في الطريق إليك';
      case OrderStatus.waitingPickup:
        return 'في انتظار الاستلام';
      case OrderStatus.delivered:
        return 'تم تسليم الطلب';
    }
  }

  Widget _buildAnimationSection() {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        image: status == OrderStatus.preparing || status == OrderStatus.onTheWay
            ? DecorationImage(
                image: AssetImage('assets/images/orders/order_tracking_bg.png'),
                fit: BoxFit.cover,
              )
            : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FAFB), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Color(0xFFF3F4F6), width: 0.76.w),
      ),
      child: _getAnimationWidget(),
    );
  }

  Widget _getAnimationWidget() {
    switch (status) {
      case OrderStatus.pendingAcceptance:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF7F22FE), width: 3.w),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7F22FE),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ننتظر رد المطعم...',
                style: TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: Color(0xFF99A1AF),
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
                  color: Color(0xFF7F22FE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'تم القبول!',
                  style: TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Color(0xFF7F22FE),
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
                  color: Color(0xFFF3F4F6).withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                    side: BorderSide(
                      width: 0.76,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.waitingPickup:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🏠', style: TextStyle(fontSize: 60.sp)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(0xFF7F22FE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'الكابتن أفينتو بالخارج...',
                  style: TextStyle().textColorBold(
                    fontSize: 12.sp,
                    color: Color(0xFF7F22FE),
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
                  color: Color(0xFF101828),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'نتمنى لك وجبة لذيذة',
                style: TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Color(0xFF6A7282),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildTimeline() {
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
              color: Color(0xFFF3F4F6),
            ),
          ),

          // Timeline Items
          Column(
            children: [
              _buildTimelineItem(
                time: '12:30',
                title: 'بانتظار قبول المطعم',
                isActive: status.index >= 0,
                isCurrent: status == OrderStatus.pendingAcceptance,
                icon: "assets/svg/client/orders/pending_acceptance.svg",
              ),

              SizedBox(height: 24.h),
              _buildTimelineItem(
                time: '12:31',
                title: 'تم تأكيد الطلب',
                isActive: status.index >= 1,
                isCurrent: status == OrderStatus.confirmed,
                icon: "assets/svg/client/orders/confirmed.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                time: '12:35',
                title: 'جاري التحضير',
                isActive: status.index >= 2,
                isCurrent: status == OrderStatus.preparing,
                icon: "assets/svg/client/orders/preparing.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                time: '12:50',
                title: 'في الطريق إليك',
                isActive: status.index >= 3,
                isCurrent: status == OrderStatus.onTheWay,
                icon: "assets/svg/client/orders/on_the_way.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                time: '01:05',
                title: 'في انتظار الاستلام',
                isActive: status.index >= 4,
                isCurrent: status == OrderStatus.waitingPickup,
                icon: "assets/svg/client/orders/waiting_pickup.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
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

  Widget _buildTimelineItem({
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
                ? Color(0xFF7F22FE)
                : (isActive ? Color(0xFF00C950) : Colors.white),
            shape: BoxShape.circle,
            border: isActive && !isCurrent
                ? Border.all(color: Color(0xFF00C950), width: 1.5.w)
                : (isCurrent
                      ? Border.all(color: Color(0xFFD1D5DC), width: 1.5.w)
                      : Border.all(color: Color(0xFFF3F4F6), width: 1.5.w)),
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
                  : (isActive ? Colors.white : Color(0xFFF3F4F6)),
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
                  ? Color(0xFF101828)
                  : (isActive
                        ? Color(0xFF6A7282)
                        : Color(0xFF6A7282).withOpacity(0.3)),
            ),
          ),
        ),
        // Time
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            time,
            style: TextStyle().textColorBold(
              fontSize: 10.sp,
              color: Color(0xFF99A1AF),
            ),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFF3F4F6), width: 0.76.w),
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
                  color: Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF101828),
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
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFE5E7EB), width: 0.76.w),
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
                          color: Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'كيا سيراتو • أبيض',
                        style: TextStyle().textColorNormal(
                          fontSize: 10.sp,
                          color: Color(0xFF6A7282),
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
