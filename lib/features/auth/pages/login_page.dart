import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/reusable/svg_icon.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if(kDebugMode){
      _usernameController.text = "mohamed";
      _passwordController.text = "123456";
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                // Logo or Icon
                Center(
                  child: SvgIcon(
                    iconName: 'assets/svg/logo.svg',
                    width: 80.w,
                    height: 80.h,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 32.h),
                // Title
                Text(
                  'مرحباً بك',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    fontFamily: "IBMPlexSansArabic"
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'سجل دخولك للمتابعة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                // Username Field
                _buildTextField(
                  controller: _usernameController,
                  label: 'اسم المستخدم',
                  hint: 'أدخل اسم المستخدم',
                  prefixIcon: 'auth/phone',
                  prefixIconWidget: Icon(Icons.person, color: Color(0xFF9CA3AF),),
                  keyboardType: TextInputType.text,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'اسم المستخدم'),
                ),
                SizedBox(height: 16.h),
                // Password Field
                Obx(
                  () => _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    prefixIcon: 'auth/lock',
                    prefixIconWidget: Icon(Icons.lock, color: Color(0xFF9CA3AF),),
                    obscureText: controller.obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    validator: Validators.password,
                  ),
                ),
                SizedBox(height: 8.h),
                // Forget Password Link
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgetPassword),
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Login Button
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.login(
                                _usernameController.text,
                                _passwordController.text,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefixIcon,
    required Widget prefixIconWidget,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: prefixIconWidget
              // child: SvgIcon(
              //   iconName: prefixIcon,
              //   width: 20.w,
              //   height: 20.h,
              //   color: const Color(0xFF9CA3AF),
              // ),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE5E7EB),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE5E7EB),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error, width: 1.w),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }
}
