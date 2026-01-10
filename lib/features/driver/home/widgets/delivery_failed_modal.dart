import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../models/driver_order_model.dart';

class DeliveryFailedModal extends StatelessWidget {
  final DriverOrderModel order;

  const DeliveryFailedModal({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 36.r,
              color: AppColors.notificationRed,
            ),
          ),

          SizedBox(height: 24.h),

          // Title
          Text(
            'تعذر تسليم الطلب',
            style: const TextStyle().textColorBold(
              fontSize: 20,
              color: AppColors.textDark,
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            'يرجى التواصل مع الدعم الفني للإبلاغ عن المشكلة (عدم تواجد العميل، عنوان خاطئ، إلخ) لاتخاذ الإجراء المناسب.',
            textAlign: TextAlign.center,
            style: const TextStyle().textColorNormal(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),

          SizedBox(height: 24.h),

          // Action buttons
          Column(
            children: [
              // Contact support button
              CustomButtonApp(
                text: 'اتصال بالدعم الفني',
                onTap: () async {
                  // TODO: Replace with actual support phone number
                  final uri = Uri.parse('tel:+218912345678');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                color: AppColors.primary,
                height: 56.h,
                borderRadius: 14.r,
                textStyle: const TextStyle().textColorBold(
                  fontSize: 18,
                  color: Colors.white,
                ),
                icon: Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 16.r,
                ),
              ),
              SizedBox(height: 12.h),
              // Back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text(
                      'العودة لمحاولة التسليم',
                      style: const TextStyle().textColorMedium(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

