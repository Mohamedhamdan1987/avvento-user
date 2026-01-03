import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import 'svg_icon.dart';

class ProductLinkInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPaste;
  final VoidCallback onSubmit;

  const ProductLinkInput({
    super.key,
    required this.controller,
    required this.onPaste,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onPaste,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: SvgIcon(
                iconName: 'assets/svg/link.svg',
                width: 16.w,
                height: 16.h,
                color: AppColors.textSecondary,
                padding: EdgeInsets.all(12.r),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'الصق رابط المنتج هنا...',
                hintStyle: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
              ),
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16.sp, color: Colors.black),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onSubmit,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: 3.1415926535 ,
                child: SvgIcon(
                  iconName: 'assets/svg/arrow_forward.svg',
                  width: 16.w,
                  height: 16.h,
                  padding: EdgeInsets.all(12.r),
                  // color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
