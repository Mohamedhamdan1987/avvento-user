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

class OtpVerificationPage extends StatelessWidget {
  final String phone;
  final bool isFromRegister;

  const OtpVerificationPage({
    super.key,
    required this.phone,
    this.isFromRegister = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من الرمز'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'أدخل رمز التحقق',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'تم إرسال رمز التحقق إلى $phone',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButtonApp(
                text: 'تحقق',
                onTap: controller.isLoading.value
                    ? null
                    : () {
                        if (otpController.text.length != 6) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى إدخال رمز التحقق كاملاً',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        // TODO: Implement OTP verification
                        Get.snackbar(
                          'نجح',
                          'تم التحقق بنجاح',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Resend OTP
                Get.snackbar(
                  'نجح',
                  'تم إعادة إرسال الرمز',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text('إعادة إرسال الرمز'),
            ),
          ],
        ),
      ),
    );
  }
}

