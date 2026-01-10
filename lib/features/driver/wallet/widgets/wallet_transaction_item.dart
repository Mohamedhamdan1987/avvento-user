import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletTransactionItem extends StatelessWidget {
  final String type; // 'credit' or 'debit'
  final double amount;
  final String title;
  final String description;
  final IconData icon;

  const WalletTransactionItem({
    super.key,
    required this.type,
    required this.amount,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = type == 'credit';
    final iconBackgroundColor = isCredit
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    final amountColor = isCredit
        ? const Color(0xFF00A63E)
        : const Color(0xFFE7000B);

    return Container(
      padding: EdgeInsetsDirectional.all(16.76.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray.withOpacity(0.1),
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
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: const TextStyle().textColorNormal(
                          fontSize: 12.sp,
                          color: const Color(0xFF99A1AF),
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
                  child: Icon(
                    icon,
                    size: 18.r,
                    color: amountColor,
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