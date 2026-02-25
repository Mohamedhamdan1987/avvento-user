import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/driver_order_model.dart';
import '../controllers/driver_orders_controller.dart';

class OrdersListBottomSheet extends StatelessWidget {
  final String title;
  final List<DriverOrderModel> orders;
  final bool isNearby;

  const OrdersListBottomSheet({
    super.key,
    required this.title,
    required this.orders,
    this.isNearby = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverOrdersController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle().textColorBold(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Text(
                      '${orders.length}',
                      style: const TextStyle().textColorBold(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: orders.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(context, order, controller);
                      },
                    ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.r,
            color: Theme.of(context).hintColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد طلبات حالياً',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    DriverOrderModel order,
    DriverOrdersController controller,
  ) {
    final distanceKm = geo.Geolocator.distanceBetween(
      order.pickupLocation.latitude,
      order.pickupLocation.longitude,
      order.deliveryLocation.latitude,
      order.deliveryLocation.longitude,
    ) / 1000;
    final estimatedMinutes = (distanceKm / 30 * 60).round();

    return GestureDetector(
      onTap: () {
        Get.back();
        controller.selectOrder(order);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.76.w,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant row + price
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: order.restaurantLogo != null && order.restaurantLogo!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: order.restaurantLogo!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Icon(Icons.store_outlined, size: 20.r, color: AppColors.primary),
                          errorWidget: (_, __, ___) => Icon(Icons.store_outlined, size: 20.r, color: AppColors.primary),
                        )
                      : Icon(Icons.store_outlined, size: 20.r, color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: const TextStyle().textColorBold(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle().textColorNormal(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${order.deliveryFee?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2)} د.ل',
                    style: const TextStyle().textColorBold(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            SizedBox(height: 12.h),

            // Customer data is hidden for nearby (unaccepted) orders
            Row(
              children: [
                if (isNearby) ...[
                  Icon(Icons.lock_outline, size: 14.r, color: Theme.of(context).hintColor),
                  SizedBox(width: 6.w),
                  Text(
                    'بيانات العميل مخفية حتى قبول الطلب',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ] else ...[
                  Icon(Icons.person_outline, size: 14.r, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Text(
                    order.customerName,
                    style: const TextStyle().textColorNormal(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: order.paymentMethod == 'cash'
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    order.paymentMethod == 'cash' ? 'نقدي' : order.paymentMethod,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: order.paymentMethod == 'cash'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Pickup address
            Row(
              children: [
                Icon(Icons.store_outlined, size: 14.r, color: AppColors.primary),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    order.pickupLocation.address,
                    style: const TextStyle().textColorNormal(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Delivery address
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14.r, color: Colors.redAccent),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    order.deliveryLocation.address,
                    style: const TextStyle().textColorNormal(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Bottom metrics: items count, distance, time
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 14.r, color: Theme.of(context).hintColor),
                    SizedBox(width: 4.w),
                    Text(
                      '${order.items.length} أصناف',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route_outlined, size: 14.r, color: Theme.of(context).hintColor),
                    SizedBox(width: 4.w),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} كم',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_outlined, size: 14.r, color: Theme.of(context).hintColor),
                    SizedBox(width: 4.w),
                    Text(
                      '$estimatedMinutes د',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
