import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/utils/logger.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/features/client/restaurants/controllers/restaurants_controller.dart';
import 'package:avvento/core/enums/order_status.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
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
            _buildProgressBar(context),

            SizedBox(height: 20.h),

            // Order Header
            _buildOrderHeader(context),

            SizedBox(height: 16.h),

            // Estimated Time Section
            _buildEstimatedTimeSection(context),

            SizedBox(height: 16.h),

            // Order Items
            _buildOrderItems(context),

            SizedBox(height: 16.h),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final status = OrderStatus.fromString(order.status);
    int completedSteps = _getCompletedSteps(status);
    // Total steps excluding 'cancelled'
    int totalSteps = OrderStatus.values.where((e) => e != OrderStatus.cancelled).length;

    return Container(
      height: 4.h,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          bool isCompleted = completedSteps >= index;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
                border: isCompleted && index < totalSteps - 1
                    ? BorderDirectional(
                        end: BorderSide(color: Theme.of(context).cardColor, width: 0.76.w),
                      )
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  int _getCompletedSteps(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.deliveryReceived:
        return 3;
      case OrderStatus.onTheWay:
        return 4;
      case OrderStatus.awaitingDelivery:
        return 5;
      case OrderStatus.delivered:
        return 6;
      case OrderStatus.cancelled:
        return -1;
      default:
        return -1;
    }
  }

  Widget _buildOrderHeader(BuildContext context) {
    final status = OrderStatus.fromString(order.status);
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
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: order.restaurant.logo ?? '',
                    width: 48.w,
                    height: 48.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Container(color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Restaurant Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      style: const TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            status.label,
                            style: const TextStyle().textColorBold(
                              fontSize: 11.sp,
                              color: _getStatusColor(status),
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
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '#${order.id.substring(order.id.length - 4)}',
            style: const TextStyle().textColorBold(
              fontSize: 11.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedTimeSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
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
                    fontSize: 11.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '12:45 م', // Generic since API doesn't provide it
                  style: const TextStyle().textColorBold(
                    fontSize: 16.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'يصل خلال 15-20 دقيقة',
                  style: const TextStyle().textColorMedium(
                    fontSize: 11.sp,
                    color: const Color(0xFF00A63E),
                  ),
                ),
              ],
            ),
          ),

          // Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                width: 20.w,
                height: 20.h,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طلب يحتوي على ${order.items.length} عناصر',
          style: const TextStyle().textColorNormal(
            fontSize: 13.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'الإجمالي: ${order.totalPrice} د.ل',
          style: const TextStyle().textColorNormal(
            fontSize: 11.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Track Order Button
        Expanded(
          flex: 2,
          child: Builder(
            builder: (context) {
              // cprint('Status: ${order.status}');
              return CustomButtonApp(
                text: 'تتبع الطلب',
                onTap: () async {
                  // Get order status
                  final status = OrderStatus.fromString(order.status);

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
                height: 40.h,
                borderRadius: 10.r,
                color: AppColors.primary,
                textStyle: const TextStyle().textColorBold(
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              );
            },
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
            height: 40.h,
            borderRadius: 10.r,
            isFill: false,
            borderColor: Theme.of(context).dividerColor,
            borderWidth: 0.76.w,
            color: Theme.of(context).cardColor,
            textStyle: const TextStyle().textColorBold(
              fontSize: 13.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            childWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'الدعم',
                  style: const TextStyle().textColorBold(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(width: 6.w),
                 SvgIcon(
                  iconName: 'assets/svg/client/orders/support_icon.svg',
                  width: 14.w,
                  height: 14.h,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return AppColors.primary;
      case OrderStatus.confirmed:
        return const Color(0xFF00C950);
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.onTheWay:
        return AppColors.primary;
      case OrderStatus.delivered:
        return const Color(0xFF00C950);
      case OrderStatus.deliveryReceived:
        return const Color(0xFF00C950);
      default:
        return AppColors.primary;
    }
  }

  // String _getStatusText(String? status) {
  //   switch (status) {
  //     case 'pending_restaurant':
  //       return 'بانتظار قبول المطعم';
  //     case 'confirmed':
  //       return 'تم تأكيد الطلب';
  //     case 'preparing':
  //       return 'جاري تحضير طلبك';
  //     case 'on_the_way':
  //       return 'في الطريق إليك';
  //     case 'delivered':
  //       return 'تم تسليم الطلب';
  //     default:
  //       return 'جاري تحضير طلبك';
  //   }
  // }
}
