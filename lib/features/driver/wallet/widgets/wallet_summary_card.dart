import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';

class WalletSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color iconColor;
  final String iconName;
  final IconData fallbackIcon;

  const WalletSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.iconColor,
    required this.iconName,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final displayAmount = amount.abs();

    return Container(
      height: 133.5.h,
      padding: EdgeInsetsDirectional.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section: Icon and Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: iconColor, // Use as is, potentially specific branding
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SafeSvgIcon(
                    iconName: iconName,
                    width: 20.w,
                    height: 20.h,
                    color: AppColors.textDark, // Maybe keep dark as icon bg is light, or Theme.of(context).primaryColorDark or black depending on icon background
                    fallbackIcon: fallbackIcon,
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Title
              Text(
                title,
                style: const TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Amount at bottom
          Text(
            '${isNegative ? '-' : ''}${displayAmount.toStringAsFixed(2)}',
            style: const TextStyle().textColorBold(
              fontSize: 20.sp,
              color: isNegative ? AppColors.notificationRed : Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}