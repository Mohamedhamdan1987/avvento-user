import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'استعادة كلمة المرور',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل اسم المستخدم لإرسال رمز التحقق',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: usernameController,
              label: 'اسم المستخدم',
              hint: 'أدخل اسم المستخدم',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButtonApp(
                text: 'إرسال',
                onTap: controller.isLoading.value
                    ? null
                    : () {
                        if (usernameController.text.isEmpty) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى إدخال اسم المستخدم',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        // TODO: Implement forget password
                        Get.snackbar(
                          'نجح',
                          'سيتم إرسال رمز التحقق قريباً',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('العودة لتسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

