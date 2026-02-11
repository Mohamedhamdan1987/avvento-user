import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../theme/app_text_styles.dart';

class AppDialogs {
  /// Shows a bottom-sheet reminding the user that their current location
  /// doesn't match any saved address, offering to add a new one.
  static void showAddAddressReminder() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: AppColors.borderGray,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            // Location icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                color: AppColors.purple,
                size: 32.r,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'موقع جديد!',
              style: TextStyle().textColorBold(
                fontSize: 18.sp,
                color: Get.theme.textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Description
            Text(
              'يبدو أنك في موقع مختلف عن العناوين المحفوظة لديك.\nهل تريد إضافة عنوانك الحالي كعنوان جديد؟',
              style: TextStyle().textColorNormal(
                fontSize: 14.sp,
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Actions
            Row(
              children: [
                // Skip button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderGray),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'لاحقاً',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                        color: Get.theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Add address button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.mapSelection);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'إضافة عنوان',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static void showDeleteConfirmation({
    required String title,
    required String description,
    required Future<void> Function() onConfirm,
    String? confirmText,
    String? cancelText,
  }) {
    var confirmed = false;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle for bottom sheet
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: AppColors.borderGray,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            // Icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 32.r,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              title,
              style: TextStyle().textColorBold(
                fontSize: 18.sp,
                color: Get.theme.textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Description
            Text(
              description,
              style: TextStyle().textColorNormal(
                fontSize: 14.sp,
                color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderGray),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      cancelText ?? 'إلغاء',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                        color: Get.theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (confirmed) return;
                      confirmed = true;
                      Get.back();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      confirmText ?? 'حذف',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
