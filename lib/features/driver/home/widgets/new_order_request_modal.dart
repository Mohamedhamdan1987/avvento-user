import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../models/driver_order_model.dart';
import '../controllers/driver_orders_controller.dart';

class NewOrderRequestModal extends StatelessWidget {
  final DriverOrderModel order;

  const NewOrderRequestModal({
    super.key,
    required this.order,
  });

  // Calculate distance between two points
  String _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final distance = geo.Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    final distanceKm = distance / 1000;
    return '${distanceKm.toStringAsFixed(1)} كم';
  }

  // Estimate delivery time based on distance
  String _estimateTime(double distanceKm) {
    // Assuming average speed of 30 km/h in city
    final minutes = (distanceKm / 30 * 60).round();
    return '$minutes دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverOrdersController>();

    // Calculate distance and time from pickup to delivery location
    final distanceKm = geo.Geolocator.distanceBetween(
      order.pickupLocation.latitude,
      order.pickupLocation.longitude,
      order.deliveryLocation.latitude,
      order.deliveryLocation.longitude,
    ) / 1000;
    
    final distance = _calculateDistance(
      order.pickupLocation.latitude,
      order.pickupLocation.longitude,
      order.deliveryLocation.latitude,
      order.deliveryLocation.longitude,
    );
    final estimatedTime = _estimateTime(distanceKm);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top indicator bar
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.only(
              start: 36.535.w,
              end: 0,
            ),
            child: Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with price badge and title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'طلب جديد',
                          style: const TextStyle().textColorBold(
                            fontSize: 20,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'لديك 30 ثانية للقبول',
                          style: const TextStyle().textColorNormal(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),

                    // Price badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        '${order.deliveryFee?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2)} د.ل',
                        style: const TextStyle().textColorBold(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
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
                      // Restaurant icon
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
                          Icons.store_outlined,
                          color: AppColors.primary,
                          size: 24.r,
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Restaurant info (left side in RTL)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Rating badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 10.r,
                                        color: const Color(0xFFFE9A00),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        '4.5', // TODO: Get from restaurant data
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFFFE9A00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Restaurant name
                                Text(
                                  order.restaurantName,
                                  style: const TextStyle().textColorBold(
                                    fontSize: 18,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
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
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Metrics row (time and distance)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.location_on_outlined,
                        label: 'المسافة',
                        value: distance,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.access_time_outlined,
                        label: 'الوقت المقدر',
                        value: estimatedTime,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonApp(
                        text: 'رفض',
                        onTap: () {
                          controller.rejectOrder(order.id);
                          Navigator.pop(context);
                          controller.clearSelectedOrder();
                        },
                        isFill: false,
                        borderColor: AppColors.borderGray,
                        borderWidth: 1.5.w,
                        height: 56.h,
                        borderRadius: 16.r,
                        textStyle: const TextStyle().textColorBold(
                          fontSize: 18,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButtonApp(
                        text: 'قبول الطلب',
                        onTap: () {
                          controller.acceptOrder(order.id);
                          Navigator.pop(context);
                          controller.clearSelectedOrder();
                        },
                        color: AppColors.primary,
                        height: 56.h,
                        borderRadius: 16.r,
                        textStyle: const TextStyle().textColorBold(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        isLoading: controller.isAccepting,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
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
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18.r,
            color: AppColors.textDark,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: const TextStyle().textColorNormal(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: const TextStyle().textColorBold(
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
