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

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'إنشاء حساب جديد',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'املأ البيانات التالية للتسجيل',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: nameController,
              label: 'الاسم الكامل',
              hint: 'أدخل الاسم الكامل',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: usernameController,
              label: 'اسم المستخدم',
              hint: 'أدخل اسم المستخدم',
              prefixIcon: Icons.account_circle,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              label: 'البريد الإلكتروني',
              hint: 'أدخل البريد الإلكتروني',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: phoneController,
              label: 'رقم الهاتف',
              hint: 'أدخل رقم الهاتف',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
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
            const SizedBox(height: 16),
            CustomTextField(
              controller: addressController,
              label: 'العنوان (اختياري)',
              hint: 'أدخل العنوان',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 32),
            Obx(
              () => CustomButtonApp(
                text: 'إنشاء حساب',
                onTap: controller.isRegisterLoading.value
                    ? null
                    : () {
                        if (nameController.text.isEmpty ||
                            usernameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى ملء جميع الحقول المطلوبة',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          Get.snackbar(
                            'خطأ',
                            'كلمات المرور غير متطابقة',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        controller.register(
                          name: nameController.text.trim(),
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          password: passwordController.text,
                          address: addressController.text.isNotEmpty
                              ? addressController.text.trim()
                              : null,
                        );
                      },
                isLoading: controller.isRegisterLoading.value,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('لديك حساب بالفعل؟ '),
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('سجل الدخول'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

