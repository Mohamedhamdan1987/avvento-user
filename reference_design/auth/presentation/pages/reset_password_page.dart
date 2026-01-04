import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_text_field.dart';

import 'package:avvento/core/constants/app_colors.dart';

import '../controllers/auth_controller.dart';

import '../controllers/auth_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final String userName;

  const ResetPasswordPage({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة تعيين كلمة المرور'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'إعادة تعيين كلمة المرور',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'أدخل كلمة المرور الجديدة لـ $userName',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: otpController,
              label: 'رمز التحقق',
              hint: 'أدخل رمز التحقق',
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: newPasswordController,
              label: 'كلمة المرور الجديدة',
              hint: 'أدخل كلمة المرور الجديدة',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              hint: 'أعد إدخال كلمة المرور',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButtonApp(
                text: 'إعادة التعيين',
                onTap: controller.isLoading.value
                    ? null
                    : () {
                        if (newPasswordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty ||
                            otpController.text.isEmpty) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى ملء جميع الحقول',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          Get.snackbar(
                            'خطأ',
                            'كلمات المرور غير متطابقة',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // TODO: Implement reset password
                        Get.snackbar(
                          'نجح',
                          'تم إعادة تعيين كلمة المرور بنجاح',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        Get.back();
                      },
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

