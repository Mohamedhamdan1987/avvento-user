import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
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
          
          // List
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
    return GestureDetector(
      onTap: () {
        Get.back(); // Close list
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.restaurantName,
                      style: const TextStyle().textColorBold(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
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
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14.r, color: AppColors.primary),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    isNearby ? order.pickupLocation.address : order.deliveryLocation.address,
                    style: const TextStyle().textColorNormal(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.access_time_outlined, size: 14.r, color: Theme.of(context).hintColor),
                SizedBox(width: 4.w),
                Text(
                  '15 دقيقة', // Mock time
                  style: const TextStyle().textColorNormal(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
