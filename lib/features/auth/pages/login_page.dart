import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../core/widgets/reusable/custom_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    if (kDebugMode) {
      // Pre-fill for testing purposes
      // // usernameController.text = 'mohamed';
      // usernameController.text = 'driver';
      // passwordController.text = '1234567';
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = usernameController.text;
    final password = passwordController.text;

    // Safely get or initialize AuthController
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    controller.login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  // Logo or Icon
                  Center(
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.drawerPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.drawerPurple,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 50.sp,
                        color: AppColors.drawerPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // Welcome Text
                  Text(
                    'مرحباً بك',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'سجل دخولك للاستمرار',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),
                  // Username Field
                  CustomTextField(
                    controller: usernameController,
                    label: 'اسم المستخدم أو البريد الإلكتروني',
                    hint: 'أدخل اسم المستخدم',
                    prefixIcon: Icons.person_outline,
                    borderRadius: 16,
                    borderColor: AppColors.drawerPurple.withOpacity(0.2),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  // Password Field
                  CustomTextField(
                    controller: passwordController,
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    borderRadius: 16,
                    borderColor: AppColors.drawerPurple.withOpacity(0.2),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.forgetPassword);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.drawerPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Login Button
                  Obx(() {
                    final controller = Get.put(AuthController());
                    return Container(
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
                        text: 'تسجيل الدخول',
                        color: AppColors.drawerPurple,
                        onTap: _handleLogin,
                        isLoading: controller.isLoading,
                        borderRadius: 16,
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 8,
                      children: [
                        Obx(() {
                          final controller = Get.find<AuthController>();
                          return Expanded(
                            child: Container(
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
                                text: 'mohamed',
                                color: AppColors.drawerPurple,
                                onTap: () {
                                  controller.login("mohamed", "1234567");
                                },
                                isLoading: controller.isLoading,
                                borderRadius: 16,
                              ),
                            ),
                          );
                        }),
                        Obx(() {
                          final controller = Get.find<AuthController>();
                          return Expanded(
                            child: Container(
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
                                text: 'driver',
                                color: AppColors.drawerPurple,
                                onTap: () {
                                  controller.login("driver", "1234567");
                                },
                                isLoading: controller.isLoading,
                                borderRadius: 16,
                              ),
                            ),
                          );
                        }),
                        Obx(() {
                          final controller = Get.find<AuthController>();
                          return Expanded(
                            child: Container(
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
                                text: 'masterpay',
                                color: AppColors.drawerPurple,
                                onTap: () {
                                  controller.login("masterpay", "1234567");
                                },
                                isLoading: controller.isLoading,
                                borderRadius: 16,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'أو',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.register);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        ),
                        child: Text(
                          'سجل الآن',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.drawerPurple,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.drawerPurple,
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
      ),
    );
  }
}
