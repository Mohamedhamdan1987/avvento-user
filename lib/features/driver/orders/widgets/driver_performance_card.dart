import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';

class DriverPerformanceCard extends StatelessWidget {
  const DriverPerformanceCard({super.key});

  @override
  @override
  Widget build(BuildContext context) {
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
                widthFactor: 0.75, // 75% progress (342 out of ~450 for platinum)
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
                                      'سائق ذهبي',
                                      style: const TextStyle().textColorBold(
                                        fontSize: 18.sp,
                                        color: Theme.of(context).textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Golden badge icon
                                    SafeSvgIcon(
                                      iconName: 'assets/svg/driver/orders/gold_badge.svg',
                                      width: 16.w,
                                      height: 16.h,
                                      color: const Color(0xFFF0B100),
                                      fallbackIcon: Icons.workspace_premium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'أكمل 25 طلب للوصول للمستوى البلاتيني',
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
                        'مستوى 4',
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
                      child: _buildStatCard(
                        context,
                        value: '342',
                        label: 'طلب مكتمل',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Rating (middle)
                    Expanded(
                      child: _buildStatCard(
                        context,
                        value: '4.9',
                        label: 'التقييم العام',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Acceptance Rate (on the left in RTL)
                    Expanded(
                      child: _buildStatCard(
                        context,
                        value: '98%',
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
}