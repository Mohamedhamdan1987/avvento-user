import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';

class WalletTransactionItem extends StatelessWidget {
  final String type; // 'credit' or 'debit'
  final double amount;
  final String title;
  final String description;
  final String iconName;
  final IconData fallbackIcon;

  const WalletTransactionItem({
    super.key,
    required this.type,
    required this.amount,
    required this.title,
    required this.description,
    required this.iconName,
    required this.fallbackIcon,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final isCredit = type == 'credit';
    final amountColor = isCredit
        ? const Color(0xFF00A63E)
        : const Color(0xFFE7000B);
    final iconBackgroundColor = amountColor.withOpacity(0.1);

    return Container(
      padding: EdgeInsetsDirectional.all(16.76.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Amount (on the left in RTL, left = end)
          Text(
            '${isCredit ? '+' : '-'}${amount.toStringAsFixed(2)} د.ل',
            style: const TextStyle().textColorBold(
              fontSize: 16.sp,
              color: amountColor,
            ),
          ),

          SizedBox(width: 12.w),

          // Transaction Info (on the right in RTL, right = start)
          Expanded(
            child: Row(
              children: [
                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: const TextStyle().textColorNormal(
                          fontSize: 12.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // Icon Circle
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SafeSvgIcon(
                      iconName: iconName,
                      width: 18.r,
                      height: 18.r,
                      color: amountColor,
                      fallbackIcon: fallbackIcon,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}