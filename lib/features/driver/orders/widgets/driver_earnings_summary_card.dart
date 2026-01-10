import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';

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
    return Container(
      padding: EdgeInsetsDirectional.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderLightGray.withOpacity(0.1),
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
                      color: AppColors.textDark,
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
                  color: AppColors.borderLightGray,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodButton('يومي', 'يومي'),
                    _buildPeriodButton('أسبوعي', 'أسبوعي'),
                    _buildPeriodButton('شهري', 'شهري'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Bar Chart
          SizedBox(
            height: 200.h,
            child: _buildBarChart(),
          ),
          SizedBox(height: 16.h),

          // Total Earnings Footer
          Container(
            padding: EdgeInsetsDirectional.only(top: 0.76.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.borderGray,
                  width: 0.76.w,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total amount (on the left in RTL)
                Text(
                  '1,640 د.ل',
                  style: const TextStyle().textColorBold(
                    fontSize: 18.sp,
                    color: AppColors.textDark,
                  ),
                ),

                // Label (on the right in RTL)
                Text(
                  'إجمالي أرباح هذا الأسبوع',
                  style: const TextStyle().textColorMedium(
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () => onPeriodChanged(period),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.76.w,
          vertical: 4.76.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
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
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Mock data for the week
    final weeklyData = [
      {'day': 'السبت', 'value': 0.65},
      {'day': 'الأحد', 'value': 0.50},
      {'day': 'الاثنين', 'value': 0.58},
      {'day': 'الثلاثاء', 'value': 0.45},
      {'day': 'الأربعاء', 'value': 0.55},
      {'day': 'الخميس', 'value': 0.70},
      {'day': 'الجمعة', 'value': 1.0}, // Highest bar
    ];

    return Column(
      children: [
        // Chart bars
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weeklyData.asMap().entries.map((entry) {
              final data = entry.value;
              final isHighest = data['value'] == 1.0;

              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 2.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 160.h * (data['value'] as double),
                        decoration: BoxDecoration(
                          color: isHighest
                              ? AppColors.primary
                              : AppColors.borderLightGray,
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(4.r),
                            topEnd: Radius.circular(4.r),
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

        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weeklyData.map((data) {
            return Expanded(
              child: Text(
                data['day'] as String,
                style: const TextStyle().textColorNormal(
                  fontSize: 10.sp,
                  color: const Color(0xFF9CA3AF),
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