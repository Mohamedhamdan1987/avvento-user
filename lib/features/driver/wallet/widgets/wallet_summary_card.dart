import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color iconColor;
  final IconData icon;

  const WalletSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final displayAmount = amount.abs();

    return Container(
      height: 133.5.h,
      padding: EdgeInsetsDirectional.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray.withOpacity(0.1),
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
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20.r,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 10.h),

              // Title
              Text(
                title,
                style: const TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
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
              color: isNegative ? AppColors.notificationRed : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}