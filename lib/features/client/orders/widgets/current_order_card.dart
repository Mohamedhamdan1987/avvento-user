import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/features/client/restaurants/controllers/restaurants_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import 'order_tracking_dialog.dart';

class CurrentOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const CurrentOrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 0.76.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            _buildProgressBar(),

            SizedBox(height: 40.h),

            // Order Header
            _buildOrderHeader(),

            SizedBox(height: 24.h),

            // Estimated Time Section
            _buildEstimatedTimeSection(),

            SizedBox(height: 24.h),

            // Order Items
            _buildOrderItems(),

            SizedBox(height: 24.h),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final status = order.status;
    int completedSteps = _getCompletedSteps(status);

    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: completedSteps >= 1
                    ? const Color(0xFF7F22FE)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
                border: completedSteps >= 1
                    ? BorderDirectional(
                        end: BorderSide(color: Colors.white, width: 0.76.w),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: completedSteps >= 2
                    ? const Color(0xFF7F22FE)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
                border: completedSteps >= 2
                    ? BorderDirectional(
                        end: BorderSide(color: Colors.white, width: 0.76.w),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: completedSteps >= 3
                    ? const Color(0xFF7F22FE)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
                border: completedSteps >= 3
                    ? BorderDirectional(
                        end: BorderSide(color: Colors.white, width: 0.76.w),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: completedSteps >= 4
                    ? const Color(0xFF7F22FE)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCompletedSteps(String? status) {
    switch (status) {
      case 'pending_restaurant':
        return 0;
      case 'confirmed':
        return 1;
      case 'preparing':
        return 2;
      case 'on_the_way':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 1;
    }
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant Info
        Expanded(
          child: Row(
            children: [
              // Restaurant Image
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 0.76.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: order.restaurant.logo ?? '',
                    width: 56.w,
                    height: 56.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Container(color: const Color(0xFFF9FAFB)),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Restaurant Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      style: const TextStyle().textColorBold(
                        fontSize: 18.sp,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          order.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            _getStatusText(order.status),
                            style: const TextStyle().textColorBold(
                              fontSize: 12.sp,
                              color: _getStatusColor(order.status),
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
        // Order Number
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '#${order.id.substring(order.id.length - 4)}',
            style: const TextStyle().textColorBold(
              fontSize: 12.sp,
              color: const Color(0xFF99A1AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedTimeSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Time Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت الوصول المتوقع',
                  style: const TextStyle().textColorNormal(
                    fontSize: 12.sp,
                    color: const Color(0xFF99A1AF),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '12:45 م', // Generic since API doesn't provide it
                  style: const TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يصل خلال 15-20 دقيقة',
                  style: const TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: const Color(0xFF00A63E),
                  ),
                ),
              ],
            ),
          ),

          // Icon
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child:  Center(
              child: SvgIcon(
                iconName: 'assets/svg/client/orders/clock_icon.svg',
                width: 24.w,
                height: 24.h,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طلب يحتوي على ${order.items.length} عناصر',
          style: const TextStyle().textColorNormal(
            fontSize: 14.sp,
            color: const Color(0xFF4A5565),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'الإجمالي: ${order.totalPrice} د.ل',
          style: const TextStyle().textColorNormal(
            fontSize: 12.sp,
            color: const Color(0xFF99A1AF),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Track Order Button
        Expanded(
          flex: 2,
          child: Builder(
            builder: (context) => CustomButtonApp(
              text: 'تتبع الطلب',
              onTap: () async {
                // Get order status
                final statusString = order.status;
                OrderStatus status;
                switch (statusString) {
                  case 'pending_restaurant':
                    status = OrderStatus.pendingAcceptance;
                    break;
                  case 'confirmed':
                    status = OrderStatus.confirmed;
                    break;
                  case 'preparing':
                    status = OrderStatus.preparing;
                    break;
                  case 'on_the_way':
                    status = OrderStatus.onTheWay;
                    break;
                  case 'delivered':
                    status = OrderStatus.delivered;
                    break;
                  default:
                    status = OrderStatus.pendingAcceptance;
                }

                // Get user location
                double? userLat = order.deliveryLat;
                double? userLong = order.deliveryLong;

                // Get restaurant location
                final restaurantLat = order.deliveryLat; // Fallback
                final restaurantLong = order.deliveryLong; // Fallback

                // Navigate to Google Maps page inside the app
                Get.toNamed(
                  AppRoutes.orderTrackingMap,
                  arguments: {
                    'userLat': userLat,
                    'userLong': userLong,
                    'restaurantLat': restaurantLat,
                    'restaurantLong': restaurantLong,
                    'orderId': order.id,
                    'status': status,
                  },
                );
              },
              height: 48.h,
              borderRadius: 14.r,
              color: const Color(0xF07F22FE).withOpacity(0.94),
              textStyle: const TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Support Button
        Expanded(
          child: CustomButtonApp(
            text: 'الدعم',
            onTap: () {
              Get.toNamed(AppRoutes.restaurantSupport);
            },
            height: 48.h,
            borderRadius: 14.r,
            isFill: false,
            borderColor: const Color(0xFFE5E7EB),
            borderWidth: 0.76.w,
            color: Colors.white,
            textStyle: const TextStyle().textColorBold(
              fontSize: 14.sp,
              color: Color(0xFF101828),
            ),
            childWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'الدعم',
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(width: 8.w),
                 SvgIcon(
                  iconName: 'assets/svg/client/orders/support_icon.svg',
                  width: 16.w,
                  height: 16.h,
                  color: Color(0xFF101828),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending_restaurant':
        return const Color(0xFF7F22FE);
      case 'confirmed':
        return const Color(0xFF00C950);
      case 'preparing':
        return const Color(0xFF7F22FE);
      case 'on_the_way':
        return const Color(0xFF7F22FE);
      case 'delivered':
        return const Color(0xFF00C950);
      default:
        return const Color(0xFF7F22FE);
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending_restaurant':
        return 'بانتظار قبول المطعم';
      case 'confirmed':
        return 'تم تأكيد الطلب';
      case 'preparing':
        return 'جاري تحضير طلبك';
      case 'on_the_way':
        return 'في الطريق إليك';
      case 'delivered':
        return 'تم تسليم الطلب';
      default:
        return 'جاري تحضير طلبك';
    }
  }
}
