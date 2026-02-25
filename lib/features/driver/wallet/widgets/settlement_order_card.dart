import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/settlement_model.dart';

class SettlementOrderCard extends StatelessWidget {
  final SettlementOrder order;

  const SettlementOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isPending = order.settlementStatus == 'pending';

    return Container(
      padding: EdgeInsetsDirectional.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Restaurant logo
              if (order.restaurant != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: order.restaurant!.logo,
                    width: 42.w,
                    height: 42.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 42.w,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.store, size: 20.r, color: Theme.of(context).hintColor),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 42.w,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.store, size: 20.r, color: Theme.of(context).hintColor),
                    ),
                  ),
                ),
              if (order.restaurant != null) SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant?.name ?? 'طلب ${order.orderType}',
                      style: const TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle().textColorNormal(
                        fontSize: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isPending ? 'معلقة' : 'تمت',
                  style: const TextStyle().textColorMedium(
                    fontSize: 11.sp,
                    color: isPending
                        ? const Color(0xFFEA580C)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Container(
            padding: EdgeInsetsDirectional.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  'إجمالي الطلب',
                  '${order.totalPrice.toStringAsFixed(2)} د.ل',
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(
                  context,
                  'رسوم التوصيل',
                  '${order.deliveryFee.toStringAsFixed(2)} د.ل',
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(
                  context,
                  'طريقة الدفع',
                  _paymentMethodText(order.paymentMethod),
                ),
                SizedBox(height: 6.h),
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  height: 1,
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(
                  context,
                  'مبلغ التسوية',
                  '${order.settlementAmount.toStringAsFixed(2)} د.ل',
                  valueColor: isPending
                      ? const Color(0xFFEA580C)
                      : AppColors.successGreen,
                  isBold: true,
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Icon(Icons.access_time, size: 14.r, color: Theme.of(context).hintColor),
              SizedBox(width: 4.w),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle().textColorNormal(
                  fontSize: 11.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
              if (order.deliveredAt != null) ...[
                SizedBox(width: 12.w),
                Icon(Icons.check_circle_outline, size: 14.r, color: AppColors.successGreen),
                SizedBox(width: 4.w),
                Text(
                  'تم التوصيل ${_formatTime(order.deliveredAt!)}',
                  style: const TextStyle().textColorNormal(
                    fontSize: 11.sp,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle().textColorNormal(
            fontSize: 12.sp,
            color: Theme.of(context).hintColor,
          ),
        ),
        Text(
          value,
          style: isBold
              ? const TextStyle().textColorBold(
                  fontSize: 13.sp,
                  color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                )
              : const TextStyle().textColorMedium(
                  fontSize: 12.sp,
                  color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
        ),
      ],
    );
  }

  String _paymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'wallet':
        return 'محفظة';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
