import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

showSnackBar({
  required String message,
  String? title,
  Color? bgColor,
  bool isError = false,
  bool isSuccess = false,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      // elevation: 0,
      messageText: Container(
        width: double.infinity,
        // margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 0.76,
              color: Color(0xFFF2F4F6),
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          shadows: [
            const BoxShadow(
              color: Color(0x19000000),
              blurRadius: 10,
              offset: Offset(0, 8),
              spreadRadius: -6,
            ),
            const BoxShadow(
              color: Color(0x19000000),
              blurRadius: 25,
              offset: Offset(0, 20),
              spreadRadius: -5,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: ShapeDecoration(
                color: isError
                    ? Colors.red.withOpacity(0.1)
                    : isSuccess
                        ? const Color(0x197F22FE) // Purple theme
                        : const Color(0x197F22FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  isError
                      ? 'assets/svg/client/orders/cancel_icon.svg'
                      : isSuccess
                          ? 'assets/svg/client/orders/check_icon.svg'
                          : 'assets/svg/notification.svg',
                  colorFilter: ColorFilter.mode(
                    isError
                        ? Colors.red
                        : isSuccess
                            ? const Color(0xFF7F22FE)
                            : const Color(0xFF7F22FE),
                    BlendMode.srcIn,
                  ),
                  width: 20.r,
                  height: 20.r,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? (isError ? 'خطأ' : isSuccess ? 'نجاح' : 'تنبيه'),
                    style: TextStyle(
                      color: const Color(0xFF101727),
                      fontSize: 14.sp,
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                  Text(
                    message,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: const Color(0xFF697282),
                      fontSize: 14.sp,
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'الآن',
              style: TextStyle(
                color: const Color(0xFF99A1AE),
                fontSize: 12.sp,
                fontFamily: 'IBMPlexSansArabic',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  });
}