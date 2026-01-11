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

  const ActiveOrderView({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverOrdersController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
      Builder(builder: (context) {
        // Show different views based on order status
        switch (order.status.toLowerCase()) {
          case 'accepted':
          case 'awaiting_delivery':
            return _buildGoingToRestaurantView(context, order, controller);
          case 'at_restaurant':
            return _buildAtRestaurantView(context, order, controller);
          case 'picked_up':
          case 'going_to_customer':
            return _buildGoingToCustomerView(context, order, controller);
          case 'at_customer':
            return _buildAtCustomerView(context, order, controller);
          default:
            return const SizedBox.shrink();
        }
      },)
    ],);


  }

  // Going to Restaurant View
  Widget _buildGoingToRestaurantView(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
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
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'توجه إلى نقطة الاستلام',
                    style: const TextStyle().textColorMedium(
                      fontSize: 14,
                      color: AppColors.textLight,
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
              color: AppColors.lightBackground,
              border: Border.all(
                color: AppColors.borderLightGray,
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
                      onTap: () {
                        // TODO: Open navigation
                      },
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
                      color: Colors.white,
                      borderColor: AppColors.borderLightGray,
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
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        order.pickupLocation.address,
                        style: const TextStyle().textColorNormal(
                          fontSize: 12,
                          color: AppColors.textLight,
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
                    color: Colors.white,
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
            text: 'وصلت للمطعم',
            onTap: () {
              controller.updateOrderStatus(
                orderId: order.id,
                status: 'at_restaurant',
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
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
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
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'تأكيد استلام الطلب رقم #${order.orderNumber}',
                    style: const TextStyle().textColorMedium(
                      fontSize: 14,
                      color: AppColors.textLight,
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
              color: AppColors.lightBackground,
              border: Border.all(
                color: AppColors.borderLightGray,
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
                      onTap: () {
                        // TODO: Open navigation
                      },
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
                      color: Colors.white,
                      borderColor: AppColors.borderLightGray,
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
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        order.pickupLocation.address,
                        style: const TextStyle().textColorNormal(
                          fontSize: 12,
                          color: AppColors.textLight,
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
                    color: Colors.white,
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
              color: AppColors.lightBackground.withOpacity(0.5),
              border: Border.all(
                color: AppColors.borderGray,
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
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.borderLightGray,
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
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      'رقم الطلب',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: AppColors.textLight,
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
                        color: AppColors.textLight,
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
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
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
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'توجه إلى موقع التسليم',
                    style: const TextStyle().textColorMedium(
                      fontSize: 14,
                      color: AppColors.textLight,
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
              color: AppColors.lightBackground,
              border: Border.all(
                color: AppColors.borderLightGray,
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
                      onTap: () {
                        // TODO: Open navigation
                      },
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
                      color: Colors.white,
                      borderColor: AppColors.borderLightGray,
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
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${order.customerName} - ${order.deliveryLocation.address}',
                        style: const TextStyle().textColorNormal(
                          fontSize: 12,
                          color: AppColors.textLight,
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
                    color: Colors.white,
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
                status: 'at_customer',
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
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
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
                    color: Colors.white,
                    borderColor: AppColors.borderLightGray,
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
                          color: Colors.white,
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
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'تسليم الطلب',
                    style: const TextStyle().textColorMedium(
                      fontSize: 14,
                      color: AppColors.textLight,
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
              color: AppColors.lightBackground,
              border: Border.all(
                color: AppColors.borderLightGray,
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
                      onTap: () {
                        // TODO: Open navigation
                      },
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
                      color: Colors.white,
                      borderColor: AppColors.borderLightGray,
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
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${order.customerName} - ${order.deliveryLocation.address}',
                        style: const TextStyle().textColorNormal(
                          fontSize: 12,
                          color: AppColors.textLight,
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
                    color: Colors.white,
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
              color: AppColors.lightBackground.withOpacity(0.5),
              border: Border.all(
                color: AppColors.borderGray,
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
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.borderLightGray,
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
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      'رقم الطلب',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: AppColors.textLight,
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
                        color: AppColors.textLight,
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
                    status: 'delivered',
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
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
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
    );
  }
}

