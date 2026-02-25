import 'package:cached_network_image/cached_network_image.dart';
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with price badge and title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب جديد',
                            style: const TextStyle().textColorBold(
                              fontSize: 20,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'لديك 30 ثانية للقبول',
                            style: const TextStyle().textColorNormal(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
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

                  SizedBox(height: 20.h),

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
                        // Restaurant logo or icon
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
                          clipBehavior: Clip.antiAlias,
                          child: order.restaurantLogo != null && order.restaurantLogo!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: order.restaurantLogo!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Icon(
                                    Icons.store_outlined,
                                    color: AppColors.primary,
                                    size: 24.r,
                                  ),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.store_outlined,
                                    color: AppColors.primary,
                                    size: 24.r,
                                  ),
                                )
                              : Icon(
                                  Icons.store_outlined,
                                  color: AppColors.primary,
                                  size: 24.r,
                                ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.restaurantName,
                                style: const TextStyle().textColorBold(
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              SizedBox(height: 4.h),
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
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Delivery info card (without customer private data)
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
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.location_on_outlined,
                          label: 'التوصيل إلى',
                          value: order.deliveryLocation.address,
                        ),
                        Divider(height: 16.h, color: Theme.of(context).dividerColor),
                        _buildInfoRow(
                          context,
                          icon: Icons.payment_outlined,
                          label: 'الدفع',
                          value: order.paymentMethod == 'cash' ? 'نقدي' : order.paymentMethod,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Items list
                  if (order.items.isNotEmpty)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الأصناف (${order.items.length})',
                            style: const TextStyle().textColorBold(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...order.items.map((item) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.name} × ${item.quantity}',
                                  style: const TextStyle().textColorNormal(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                Text(
                                  '${item.price.toStringAsFixed(2)} د.ل',
                                  style: const TextStyle().textColorNormal(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Divider(height: 16.h, color: Theme.of(context).dividerColor),
                          _buildPriceRow(context, 'المجموع الفرعي', order.subtotal),
                          SizedBox(height: 4.h),
                          _buildPriceRow(context, 'رسوم التوصيل', order.deliveryFee ?? 0),
                          if (order.tax > 0) ...[
                            SizedBox(height: 4.h),
                            _buildPriceRow(context, 'الضريبة', order.tax),
                          ],
                          Divider(height: 16.h, color: Theme.of(context).dividerColor),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الإجمالي',
                                style: const TextStyle().textColorBold(
                                  fontSize: 15,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                '${order.totalAmount.toStringAsFixed(2)} د.ل',
                                style: const TextStyle().textColorBold(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFFFE082),
                          width: 0.76.w,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note_outlined, size: 16.r, color: const Color(0xFFFFA000)),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              order.notes!,
                              style: const TextStyle().textColorNormal(
                                fontSize: 13,
                                color: const Color(0xFF5D4037),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // Metrics row (time and distance)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          icon: Icons.location_on_outlined,
                          label: 'المسافة',
                          value: distance,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildMetricCard(
                          context,
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
                          text: 'قبول الطلب',
                          onTap: () {
                            controller.acceptOrder(order.id);
                            Get.back();
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
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomButtonApp(
                          text: 'رفض',
                          onTap: () {
                            controller.rejectOrder(order.id);
                            Get.back();
                          },
                          isFill: false,
                          borderColor: Theme.of(context).dividerColor,
                          borderWidth: 1.5.w,
                          height: 56.h,
                          borderRadius: 16.r,
                          textStyle: const TextStyle().textColorBold(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7) ?? AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          label,
          style: const TextStyle().textColorNormal(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle().textColorNormal(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle().textColorNormal(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} د.ل',
          style: const TextStyle().textColorNormal(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
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
            color: Theme.of(context).iconTheme.color,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: const TextStyle().textColorNormal(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: const TextStyle().textColorBold(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
