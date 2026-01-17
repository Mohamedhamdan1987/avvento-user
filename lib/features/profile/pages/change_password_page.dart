import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/reusable/custom_app_bar.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'تغيير كلمة المرور',
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'قم بتحديث كلمة المرور الخاصة بك لتأمين حسابك.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 32.h),
            
            // Current Password
            _buildPasswordField(
              context,
              label: 'كلمة المرور الحالية',
              hint: 'أدخل كلمة المرور الحالية',
              controller: controller.currentPasswordController,
              obscureText: controller.showCurrentPassword,
              onToggle: controller.toggleCurrentPassword,
            ),
            SizedBox(height: 24.h),

            // New Password
            _buildPasswordField(
              context,
              label: 'كلمة المرور الجديدة',
              hint: 'أدخل كلمة المرور الجديدة',
              controller: controller.newPasswordController,
              obscureText: controller.showNewPassword,
              onToggle: controller.toggleNewPassword,
            ),
            SizedBox(height: 24.h),

            // Confirm New Password
            _buildPasswordField(
              context,
              label: 'تأكيد كلمة المرور الجديدة',
              hint: 'أعد إدخال كلمة المرور الجديدة',
              controller: controller.confirmPasswordController,
              obscureText: controller.showConfirmPassword,
              onToggle: controller.toggleConfirmPassword,
            ),
            SizedBox(height: 48.h),

            // Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.changePassword(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required RxBool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => TextField(
          controller: controller,
          obscureText: !obscureText.value,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.purple, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Theme.of(context).iconTheme.color,
                size: 20.r,
              ),
              onPressed: onToggle,
            ),
          ),
        )),
      ],
    );
  }
}
