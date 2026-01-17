import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
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
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning Icon
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8), // Keep as is or use error color opacity
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFF05252), // Keep as specific error color
              size: 40.r,
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Title
          Text(
            'فشل التوصيل',
            style: const TextStyle().textColorBold(
              fontSize: 24,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Description
          Text(
            'نعتذر، لم نتمكن من إتمام عملية التوصيل. يرجى التواصل مع الدعم الفني للمساعدة.',
            textAlign: TextAlign.center,
            style: const TextStyle().textColorNormal(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          
          SizedBox(height: 32.h),
          
          // Helper Contact Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.76.w,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.headset_mic_outlined,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدعم الفني',
                        style: const TextStyle().textColorBold(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'متاح 24/7 للمساعدة',
                        style: const TextStyle().textColorNormal(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconButtonApp(
                  onTap: () {
                    // TODO: Open support chat or call
                  },
                  childWidget: Icon(Icons.arrow_forward_ios, size: 16.r,color: Theme.of(context).iconTheme.color,),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: CustomButtonApp(
                  text: 'رجوع',
                  onTap: () => Navigator.pop(context), // Changed Get.back() to Navigator.pop(context)
                  isFill: false,
                  borderColor: Theme.of(context).dividerColor,
                  borderWidth: 1.5.w,
                  height: 56.h,
                  borderRadius: 16.r,
                  textStyle: const TextStyle().textColorBold(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomButtonApp(
                  text: 'اتصل الان',
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: '920000000', // support number
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    }
                  },
                  color: AppColors.primary,
                  height: 56.h,
                  borderRadius: 16.r,
                  textStyle: const TextStyle().textColorBold(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h), // Safe area spacing
        ],
      ),
    );
  }
}
