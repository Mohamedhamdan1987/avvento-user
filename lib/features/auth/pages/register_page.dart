import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../core/widgets/reusable/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.drawerPurple),
        title: Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'املأ البيانات التالية للتسجيل',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                // Name Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: nameController,
                    label: 'الاسم الكامل',
                    hint: 'أدخل الاسم الكامل',
                    prefixIcon: Icons.person,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                // Username Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: usernameController,
                    label: 'اسم المستخدم',
                    hint: 'أدخل اسم المستخدم',
                    prefixIcon: Icons.account_circle,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل البريد الإلكتروني',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                // Phone Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: phoneController,
                    label: 'رقم الهاتف',
                    hint: 'أدخل رقم الهاتف',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    borderRadius: 16,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: passwordController,
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                // Confirm Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != passwordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                // Address Field (Optional)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.drawerPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.drawerPurple.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: addressController,
                    label: 'العنوان (اختياري)',
                    hint: 'أدخل العنوان',
                    prefixIcon: Icons.location_on,
                    borderRadius: 16,
                  ),
                ),
                SizedBox(height: 32.h),
                // Register Button
                Obx(
                  () => Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.drawerPurple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CustomButtonApp(
                      text: 'إنشاء حساب',
                      color: AppColors.drawerPurple,
                      onTap: controller.isRegisterLoading.value
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) {
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
                      borderRadius: 16,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                      child: Text(
                        'سجل الدخول',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.drawerPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
