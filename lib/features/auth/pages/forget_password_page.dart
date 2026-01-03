import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../core/widgets/reusable/custom_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
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
          'نسيت كلمة المرور',
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
                SizedBox(height: 40.h),
                Text(
                  'استعادة كلمة المرور',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'أدخل اسم المستخدم لإرسال رمز التحقق',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
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
                    prefixIcon: Icons.person,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                // Send Button
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
                      text: 'إرسال',
                      color: AppColors.drawerPurple,
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              // TODO: Implement forget password
                              Get.snackbar(
                                'نجح',
                                'سيتم إرسال رمز التحقق قريباً',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.drawerPurple.withOpacity(0.1),
                                colorText: AppColors.textDark,
                              );
                            },
                      isLoading: controller.isLoading.value,
                      borderRadius: 16,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Back to Login
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    'العودة لتسجيل الدخول',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.drawerPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
