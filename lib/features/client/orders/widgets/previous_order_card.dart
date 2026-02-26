import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class PreviousOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const PreviousOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final isCompleted = status == 'completed' || status == 'delivered' || status == 'delivery_received';
    final restaurantRating = order.orderRating?.restaurant?.rating ?? 0;
    final driverRating = order.orderRating?.driver?.rating ?? 0;
    final hasRestaurantRating = restaurantRating > 0;
    final hasDriverRating = driverRating > 0 && order.driver != null;
    final canRateRestaurant = isCompleted && !hasRestaurantRating;
    final canRateDriver = isCompleted && order.driver != null && !hasDriverRating;
    final hasPendingRatings = canRateRestaurant || canRateDriver;
    final hasAnyRating = hasRestaurantRating || hasDriverRating;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.76.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.76.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Info
                Expanded(
                  child: Row(
                    children: [
                      // Restaurant Image
                      Container(
                        width: 55.w,
                        height: 55.h,
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.76.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: CachedNetworkImage(
                            imageUrl: order.restaurant.logo ?? '',
                            width: 48.w,
                            height: 48.h,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Restaurant Name and Order Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.restaurant.name,
                              style: const TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'طلب #${order.id.substring(order.id.length - 4)}',
                              style: const TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isCompleted ? AppColors.successGreen : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcon(
                        iconName: isCompleted
                            ? 'assets/svg/client/orders/check_icon.svg'
                            : 'assets/svg/client/orders/cancel_icon.svg',
                        width: 12.w,
                        height: 12.h,
                        color: isCompleted
                            ? AppColors.successGreen
                            : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isCompleted ? 'مكتمل' : 'ملغي',
                        style: const TextStyle().textColorBold(
                          fontSize: 10.sp,
                          color: isCompleted
                              ? AppColors.successGreen
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            SizedBox(height: 12.h),

            // Order Items
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'طلب يحتوي على ${order.items.length} عناصر',
                style: const TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Footer Row
            Container(
              padding: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.76.w,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    '${order.totalPrice} د.ل',
                    style: const TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted && hasPendingRatings)
                        GestureDetector(
                          onTap: () => _handleRatingTap(
                            context,
                            canRateRestaurant: canRateRestaurant,
                            canRateDriver: canRateDriver,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14.sp,
                                  color: Colors.amber.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'تقييم',
                                  style: const TextStyle().textColorBold(
                                    fontSize: 12.sp,
                                    color: Colors.amber,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _pendingRatingTargetLabel(
                                    canRateRestaurant: canRateRestaurant,
                                    canRateDriver: canRateDriver,
                                  ),
                                  style: const TextStyle().textColorNormal(
                                    fontSize: 10,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isCompleted && hasAnyRating)
                        SizedBox(
                          width: hasPendingRatings ? 92.w : 135.w,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 14.sp,
                                color: AppColors.successGreen,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  _ratingSummaryText(
                                    restaurantRating: restaurantRating,
                                    driverRating: driverRating,
                                    hasRestaurantRating: hasRestaurantRating,
                                    hasDriverRating: hasDriverRating,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle().textColorBold(
                                    fontSize: 11,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isCompleted) SizedBox(width: 12.w),
                      // Reorder Button
                      GestureDetector(
                        onTap: () {
                          final controller = Get.find<OrdersController>();
                          controller.reorder(order.id);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgIcon(
                              iconName: 'assets/svg/client/orders/reorder_icon.svg',
                              width: 12.w,
                              height: 12.h,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'إعادة الطلب',
                              style: const TextStyle().textColorBold(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRatingTap(
    BuildContext context, {
    required bool canRateRestaurant,
    required bool canRateDriver,
  }) {
    if (canRateRestaurant && canRateDriver) {
      _showRatingTypeSheet(context);
      return;
    }

    if (canRateRestaurant) {
      _showRestaurantRatingDialog(context);
      return;
    }

    if (canRateDriver) {
      _showDriverRatingDialog(context);
    }
  }

  String _pendingRatingTargetLabel({
    required bool canRateRestaurant,
    required bool canRateDriver,
  }) {
    if (canRateRestaurant && canRateDriver) {
      return 'مطعم / سائق';
    }
    if (canRateRestaurant) {
      return 'مطعم';
    }
    return 'سائق';
  }

  String _ratingSummaryText({
    required int restaurantRating,
    required int driverRating,
    required bool hasRestaurantRating,
    required bool hasDriverRating,
  }) {
    if (hasRestaurantRating && hasDriverRating) {
      return 'مطعم $restaurantRating★ • سائق $driverRating★';
    }
    if (hasRestaurantRating) {
      return 'تقييم المطعم $restaurantRating★';
    }
    return 'تقييم السائق $driverRating★';
  }

  void _showRatingTypeSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'اختر نوع التقييم',
              style: const TextStyle().textColorBold(
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 16.h),
            _buildRatingTypeTile(
              context: context,
              icon: Icons.storefront_rounded,
              title: 'تقييم المطعم',
              subtitle: order.restaurant.name,
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                _showRestaurantRatingDialog(context);
              },
            ),
            SizedBox(height: 10.h),
            _buildRatingTypeTile(
              context: context,
              icon: Icons.delivery_dining_rounded,
              title: 'تقييم السائق',
              subtitle: order.driver?.name ?? 'السائق',
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                _showDriverRatingDialog(context);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildRatingTypeTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle().textColorBold(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle().textColorNormal(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestaurantRatingDialog(BuildContext context) {
    int rating = 0;
    final TextEditingController commentController = TextEditingController();
    final OrdersController controller = Get.find<OrdersController>();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'تقييم ${order.restaurant.name}',
                  style: const TextStyle().textColorBold(
                    fontSize: 18.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40.sp,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب رأيك هنا...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14.sp,
                    ),
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: rating == 0 || controller.isLoading.value
                          ? null
                          : () async {
                              final success = await controller.rateRestaurant(
                                restaurantId: order.restaurant.id,
                                rating: rating,
                                comment: commentController.text,
                                orderId: order.id,
                              );
                              if (success) {
                                await controller.fetchOrders();
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'إرسال التقييم',
                              style: const TextStyle().textColorBold(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
  void _showDriverRatingDialog(BuildContext context) {
    int rating = 0;
    final TextEditingController commentController = TextEditingController();
    final OrdersController controller = Get.find<OrdersController>();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'تقييم السائق ${order.driver?.name ?? ''}',
                  style: const TextStyle().textColorBold(
                    fontSize: 18.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40.sp,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب رأيك في السائق هنا...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14.sp,
                    ),
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: rating == 0 || controller.isLoading.value
                          ? null
                          : () async {
                              final success = await controller.rateDriver(
                                orderId: order.id,
                                rating: rating,
                                comment: commentController.text,
                              );
                              if (success) {
                                await controller.fetchOrders();
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                                ),
                            )
                          : Text(
                              'إرسال التقييم',
                              style: const TextStyle().textColorBold(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}

