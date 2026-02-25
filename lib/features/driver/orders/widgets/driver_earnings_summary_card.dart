import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';
import '../../home/controllers/driver_orders_controller.dart';
import '../../home/models/driver_dashboard_model.dart';

class DriverEarningsSummaryCard extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const DriverEarningsSummaryCard({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<DriverOrdersController>(
      builder: (controller) {
        final dashboard = controller.dashboardData;
        final totalEarnings = dashboard?.totalEarnings ?? 0.0;
        final chartData = dashboard?.earningsChart ?? [];

        return Container(
          padding: EdgeInsetsDirectional.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.76.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title (on the right in RTL)
                  Row(
                    children: [
                      Text(
                        'ملخص الأرباح',
                        style: const TextStyle().textColorBold(
                          fontSize: 18.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SafeSvgIcon(
                        iconName: 'assets/svg/driver/orders/arrow_up.svg',
                        width: 20.w,
                        height: 20.h,
                        color: AppColors.primary,
                        fallbackIcon: Icons.trending_up,
                      ),
                    ],
                  ),

                  // Period Filter Buttons (on the left in RTL)
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPeriodButton(context, 'يومي', 'يومي'),
                        _buildPeriodButton(context, 'أسبوعي', 'أسبوعي'),
                        _buildPeriodButton(context, 'شهري', 'شهري'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Bar Chart
              SizedBox(
                height: 200.h,
                child: _buildBarChart(context, chartData),
              ),
              SizedBox(height: 16.h),

              // Total Earnings Footer
              Container(
                padding: EdgeInsetsDirectional.only(top: 0.76.h),
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
                    // Total amount (on the left in RTL)
                    Text(
                      '${totalEarnings.toStringAsFixed(2)} د.ل',
                      style: const TextStyle().textColorBold(
                        fontSize: 18.sp,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),

                    Text(
                      _getPeriodLabel(),
                      style: const TextStyle().textColorMedium(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
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

  Widget _buildPeriodButton(BuildContext context, String period, String label) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () => onPeriodChanged(period),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.76.w,
          vertical: 4.76.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Colors.transparent,
            width: 0.76.w,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle().textColorMedium(
            fontSize: 12.sp,
            color: isSelected
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    switch (selectedPeriod) {
      case 'يومي':
        return 'إجمالي أرباح اليوم';
      case 'شهري':
        return 'إجمالي أرباح هذا العام';
      default:
        return 'إجمالي أرباح هذا الأسبوع';
    }
  }

  Widget _buildBarChart(BuildContext context, List<EarningsChartData> chartData) {
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات متاحة',
          style: const TextStyle().textColorNormal(
            fontSize: 14.sp,
            color: AppColors.textPlaceholder,
          ),
        ),
      );
    }

    final maxVal = chartData.map((e) => e.earnings).reduce((a, b) => a > b ? a : b);
    final displayData = chartData.length > 7 ? chartData.sublist(chartData.length - 7) : chartData;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: displayData.map((data) {
              final valFactor = maxVal > 0 ? data.earnings / maxVal : 0.0;
              final isHighest = data.earnings == maxVal && maxVal > 0;

              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isHighest && data.earnings > 0)
                        Padding(
                          padding: EdgeInsetsDirectional.only(bottom: 4.h),
                          child: Text(
                            data.earnings.toStringAsFixed(0),
                            style: const TextStyle().textColorBold(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      Container(
                        width: 28.w,
                        height: (140.h * valFactor).clamp(4.h, 140.h),
                        decoration: BoxDecoration(
                          color: isHighest
                              ? AppColors.primary
                              : Theme.of(context).dividerColor.withOpacity(0.3),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 8.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayData.map((data) {
            return Expanded(
              child: Text(
                data.period,
                style: const TextStyle().textColorNormal(
                  fontSize: 10.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}