import 'package:avvento/core/enums/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../models/driver_order_model.dart';
import '../controllers/driver_orders_controller.dart';
import 'delivery_failed_modal.dart';

class ActiveOrderView extends StatelessWidget {
  final DriverOrderModel order;
  final VoidCallback onNavigateToOrderLocation;

  const ActiveOrderView({
    super.key,
    required this.order,
    required this.onNavigateToOrderLocation,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverOrdersController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          // mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Handle/Toggle Button above the card
            Builder(builder: (context) {
            // Show different views based on order status
            switch (order.status) {
              case OrderStatus.pending:
              case OrderStatus.preparing:
              case OrderStatus.deliveryReceived:
                return _buildGoingToRestaurantView(context, order, controller);
              case OrderStatus.onTheWay:
                return _buildGoingToCustomerView(context, order, controller);
              case OrderStatus.awaitingDelivery:
                return _buildAtCustomerView(context, order, controller);
              case OrderStatus.delivered:
              case OrderStatus.cancelled:
                return _buildOrderFinishedView(context, order, controller);
              default:
                return _buildGoingToRestaurantView(context, order, controller);
            }
          },),
            GestureDetector(
              onTap: () => controller.toggleActiveOrdersVisibility(),
              child: Container(
                width: 48.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 20.r,
                ),
              ),
            ),


        ],),
      ],
    );


  }

  // Going to Restaurant View
  Widget _buildGoingToRestaurantView(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    final canConfirmArrival = order.status == OrderStatus.preparing;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(32.r),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.12),
        //     blurRadius: 40,
        //     offset: const Offset(0, -8),
        //   ),
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 1,
        //     offset: const Offset(0, 0),
        //   ),
        // ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 0.76.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ),

                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الذهاب للمطعم',
                      style: const TextStyle().textColorBold(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'توجه إلى نقطة الاستلام',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Restaurant info card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.76.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  // Action buttons
                  Row(
                    children: [
                      // Navigation button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: AppColors.primary,
                        onTap: onNavigateToOrderLocation,
                        childWidget: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Call button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: Theme.of(context).cardColor,
                        borderColor: Theme.of(context).dividerColor,
                        onTap: () async {
                          final uri = Uri.parse('tel:${order.pickupLocation.address}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        childWidget: Icon(
                          Icons.phone_outlined,
                          color: const Color(0xFF4CAF50),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 16.w),

                  // Restaurant info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.restaurantName,
                          style: const TextStyle().textColorBold(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          order.pickupLocation.address,
                          style: const TextStyle().textColorNormal(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Location icon
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            if (canConfirmArrival)
              CustomButtonApp(
                text: 'وصلت للمطعم',
                onTap: () {
                  controller.updateOrderStatus(
                    orderId: order.id,
                    status: OrderStatus.deliveryReceived.value,
                  );
                },
                color: AppColors.primary,
                height: 64.h,
                borderRadius: 16.r,
                textStyle: const TextStyle().textColorBold(
                  fontSize: 20,
                  color: Colors.white,
                ),
                icon: Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.0, top: 6),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 16.r,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.76.w,
                  ),
                ),
                child: Text(
                  'لا يمكن تأكيد الوصول الآن. انتظر حتى تصبح حالة الطلب "جاري التحضير".',
                  textAlign: TextAlign.center,
                  style: const TextStyle().textColorMedium(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // At Restaurant View
  Widget _buildAtRestaurantView(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 0.76.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ),

                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'في المطعم',
                      style: const TextStyle().textColorBold(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تأكيد استلام الطلب رقم #${order.orderNumber}',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Restaurant info card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.76.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  // Action buttons
                  Row(
                    children: [
                      // Navigation button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: AppColors.primary,
                        onTap: onNavigateToOrderLocation,
                        childWidget: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Call button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: Theme.of(context).cardColor,
                        borderColor: Theme.of(context).dividerColor,
                        onTap: () async {
                          final uri = Uri.parse('tel:${order.pickupLocation.address}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        childWidget: Icon(
                          Icons.phone_outlined,
                          color: const Color(0xFF4CAF50),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 16.w),

                  // Restaurant info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.restaurantName,
                          style: const TextStyle().textColorBold(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          order.pickupLocation.address,
                          style: const TextStyle().textColorNormal(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Location icon
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Order details card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.76.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.76.w,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '#${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ).textColorBold(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Text(
                        'رقم الطلب',
                        style: const TextStyle().textColorMedium(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.deliveryFee?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2)} د.ل',
                        style: const TextStyle().textColorBold(
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'المبلغ المطلوب',
                        style: const TextStyle().textColorMedium(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Confirm pickup button
            CustomButtonApp(
              text: 'تم الاستلام',
              onTap: () {
                controller.updateOrderStatus(
                  orderId: order.id,
                  status: 'picked_up',
                );
              },
              color: AppColors.primary,
              height: 64.h,
              borderRadius: 16.r,
              textStyle: const TextStyle().textColorBold(
                fontSize: 20,
                color: Colors.white,
              ),
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16.r,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Going to Customer View
  Widget _buildGoingToCustomerView(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(32.r),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.12),
        //     blurRadius: 40,
        //     offset: const Offset(0, -8),
        //   ),
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 1,
        //     offset: const Offset(0, 0),
        //   ),
        // ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 0.76.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ),

                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الذهاب للعميل',
                      style: const TextStyle().textColorBold(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'توجه إلى موقع التسليم',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Customer info card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.76.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  // Action buttons
                  Row(
                    children: [
                      // Navigation button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: AppColors.primary,
                        onTap: onNavigateToOrderLocation,
                        childWidget: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Call button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: Theme.of(context).cardColor,
                        borderColor: Theme.of(context).dividerColor,
                        onTap: () async {
                          final uri = Uri.parse('tel:${order.customerPhone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        childWidget: Icon(
                          Icons.phone_outlined,
                          color: const Color(0xFF4CAF50),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 16.w),

                  // Customer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle().textColorBold(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${order.customerName} - ${order.deliveryLocation.address}',
                          style: const TextStyle().textColorNormal(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Location icon
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Confirm arrival button
            CustomButtonApp(
              text: 'وصلت للعميل',
              onTap: () {
                controller.updateOrderStatus(
                  orderId: order.id,
                  status: OrderStatus.awaitingDelivery.value,
                );
              },
              color: AppColors.primary,
              height: 64.h,
              borderRadius: 16.r,
              textStyle: const TextStyle().textColorBold(
                fontSize: 20,
                color: Colors.white,
              ),
              icon: Padding(
                padding: EdgeInsetsDirectional.only(end:  8.0, top: 6),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 16.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // At Customer View
  Widget _buildAtCustomerView(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with notification badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Notification button with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomIconButtonApp(
                      width: 44.w,
                      height: 44.h,
                      radius: 100.r,
                      color: Theme.of(context).cardColor,
                      borderColor: Theme.of(context).dividerColor.withOpacity(0.5),
                      onTap: () {
                        // TODO: Open chat
                      },
                      childWidget: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                        size: 20.r,
                      ),
                    ),
                    PositionedDirectional(
                      top: -2.h,
                      end: -2.w,
                      child: Container(
                        width: 14.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.notificationRed,
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 0.76.w,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'عند العميل',
                      style: const TextStyle().textColorBold(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تسليم الطلب',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Customer info card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  width: 0.76.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  // Action buttons
                  Row(
                    children: [
                      // Navigation button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: AppColors.primary,
                        onTap: onNavigateToOrderLocation,
                        childWidget: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Call button
                      CustomIconButtonApp(
                        width: 44.w,
                        height: 44.h,
                        radius: 100.r,
                        color: Theme.of(context).cardColor,
                        borderColor: Theme.of(context).dividerColor.withOpacity(0.5),
                        onTap: () async {
                          final uri = Uri.parse('tel:${order.customerPhone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        childWidget: Icon(
                          Icons.phone_outlined,
                          color: const Color(0xFF4CAF50),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 16.w),

                  // Customer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle().textColorBold(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${order.customerName} - ${order.deliveryLocation.address}',
                          style: const TextStyle().textColorNormal(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Location icon
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Order details card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  width: 0.76.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.5),
                            width: 0.76.w,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '#${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ).textColorBold(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Text(
                        'رقم الطلب',
                        style: const TextStyle().textColorMedium(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.deliveryFee?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2)} د.ل',
                        style: const TextStyle().textColorBold(
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'المبلغ المطلوب',
                        style: const TextStyle().textColorMedium(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Action buttons
            Column(
              children: [
                // Deliver and collect button
                CustomButtonApp(
                  text: 'تسليم وتحصيل المبلغ',
                  onTap: () {
                    controller.updateOrderStatus(
                      orderId: order.id,
                      status: OrderStatus.delivered.value,
                    );
                  },
                  color: AppColors.successGreen,
                  height: 64.h,
                  borderRadius: 16.r,
                  textStyle: const TextStyle().textColorBold(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.r,
                  ),
                ),
                SizedBox(height: 12.h),
                // Failed delivery button
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final scaffoldState = Scaffold.maybeOf(context);

                        // Use a non-modal bottom sheet so the map behind it stays interactive.
                        if (scaffoldState != null) {
                          scaffoldState.showBottomSheet(
                            (context) => DeliveryFailedModal(order: order),
                            backgroundColor: Colors.transparent,
                            enableDrag: true,
                          );
                          return;
                        }

                        // Fallback in case no Scaffold is found in this context.
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => DeliveryFailedModal(order: order),
                        );
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            color: AppColors.notificationRed,
                            size: 16.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'تعذر تسليم الطلب',
                            style: const TextStyle().textColorMedium(
                              fontSize: 14,
                              color: AppColors.notificationRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Order Finished View (Delivered or Cancelled)
  Widget _buildOrderFinishedView(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    final isDelivered = order.status == OrderStatus.delivered;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(32.r),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.12),
        //     blurRadius: 40,
        //     offset: const Offset(0, -8),
        //   ),
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 1,
        //     offset: const Offset(0, 0),
        //   ),
        // ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Icon and Status
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: (isDelivered ? AppColors.successGreen : AppColors.notificationRed).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDelivered ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isDelivered ? AppColors.successGreen : AppColors.notificationRed,
              size: 40.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            isDelivered ? 'الطلب مكتمل' : 'تم إلغاء الطلب',
            style: const TextStyle().textColorBold(
              fontSize: 24,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'طلب رقم #${order.orderNumber}',
            style: const TextStyle().textColorMedium(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          if (isDelivered) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.deliveryFee?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2)} د.ل',
                    style: const TextStyle().textColorBold(
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'المبلغ المحصل',
                    style: const TextStyle().textColorMedium(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 32.h),

          CustomButtonApp(
            text: 'العودة للخريطة',
            onTap: () {
              controller.clearSelectedOrder();
            },
            color: AppColors.primary,
            height: 56.h,
            borderRadius: 16.r,
            textStyle: const TextStyle().textColorBold(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ));
  }
}

