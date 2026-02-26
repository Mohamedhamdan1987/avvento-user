import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';
import '../../home/controllers/driver_orders_controller.dart';

class DriverPerformanceCard extends StatelessWidget {
  const DriverPerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<DriverOrdersController>(
      builder: (controller) {
        final dashboard = controller.dashboardData;
        final isDashboardLoading = controller.isDashboardLoading;
        final deliveredOrders = dashboard?.deliveredOrders ?? 0;
        final rating = dashboard?.averageRating ?? 0.0;
        final acceptance = dashboard?.acceptancePercentage ?? 0.0;

        // Simple logic for level - could be improved based on actual requirements
        String levelName = 'سائق جديد';
        String badgeIcon = 'assets/svg/driver/orders/gold_badge.svg';
        Color badgeColor = const Color(0xFF9CA3AF);
        int level = 1;

        if (deliveredOrders >= 100) {
          levelName = 'سائق بلاتيني';
          badgeColor = const Color(0xFFE5E7EB);
          level = 5;
        } else if (deliveredOrders >= 50) {
          levelName = 'سائق ذهبي';
          badgeColor = const Color(0xFFF0B100);
          level = 4;
        } else if (deliveredOrders >= 20) {
          levelName = 'سائق فضي';
          badgeColor = const Color(0xFF94A3B8);
          level = 3;
        } else if (deliveredOrders >= 5) {
          levelName = 'سائق برونزي';
          badgeColor = const Color(0xFFB45309);
          level = 2;
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.76.w,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Progress bar at the top
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(16.r),
                      topEnd: Radius.circular(16.r),
                    ),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: (deliveredOrders % 25) / 25, // Progress to next level (mock logic)
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(16.r),
                          topEnd: Radius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 20.w,
                  end: 20.w,
                  top: 28.h,
                  bottom: 20.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Driver Level Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Driver Info (on the right in RTL)
                        Expanded(
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 48.w,
                                height: 48.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SafeSvgIcon(
                                    iconName: 'assets/svg/driver/orders/driver_level_icon.svg',
                                    width: 24.w,
                                    height: 24.h,
                                    color: AppColors.primary,
                                    fallbackIcon: Icons.local_shipping,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Driver Level Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          levelName,
                                          style: const TextStyle().textColorBold(
                                            fontSize: 18.sp,
                                            color: Theme.of(context).textTheme.titleLarge?.color,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        // Level badge icon
                                        SafeSvgIcon(
                                          iconName: badgeIcon,
                                          width: 16.w,
                                          height: 16.h,
                                          color: badgeColor,
                                          fallbackIcon: Icons.workspace_premium,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      isDashboardLoading
                                          ? 'جاري تحديث الإحصائيات...'
                                          : deliveredOrders < 100
                                          ? 'أكمل ${25 - (deliveredOrders % 25)} طلب للوصول للمستوى التالي'
                                          : 'أنت في أعلى مستوى!',
                                      style: const TextStyle().textColorNormal(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Level Badge (on the left in RTL)
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C6),
                            border: Border.all(
                              color: const Color(0xFFFEE685),
                              width: 0.76.w,
                            ),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            'مستوى $level',
                            style: const TextStyle().textColorBold(
                              fontSize: 10.sp,
                              color: const Color(0xFFBB4D00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Stats Row
                    Row(
                      children: [
                        // Completed Orders (on the right in RTL)
                        Expanded(
                          child: isDashboardLoading
                              ? _buildLoadingStatCard(context)
                              : _buildStatCard(
                                  context,
                                  value: deliveredOrders.toString(),
                                  label: 'طلب مكتمل',
                                ),
                        ),
                        SizedBox(width: 16.w),
                        // Rating (middle)
                        Expanded(
                          child: isDashboardLoading
                              ? _buildLoadingStatCard(context)
                              : _buildStatCard(
                                  context,
                                  value: rating.toStringAsFixed(1),
                                  label: 'التقييم العام',
                                ),
                        ),
                        SizedBox(width: 16.w),
                        // Acceptance Rate (on the left in RTL)
                        Expanded(
                          child: isDashboardLoading
                              ? _buildLoadingStatCard(context)
                              : _buildStatCard(
                                  context,
                                  value: '${acceptance.toInt()}%',
                                  label: 'نسبة القبول',
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
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle().textColorBold(
              fontSize: 20.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: const TextStyle().textColorNormal(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 18.w,
            height: 18.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 42.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.35),
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ],
      ),
    );
  }
}