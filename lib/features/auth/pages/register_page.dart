import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/reusable/svg_icon.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthController controller = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'املأ البيانات التالية للبدء',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: 'auth/person',
                  prefixIconWidget: Icon(Icons.person, color: Color(0xFF9CA3AF),),
                  keyboardType: TextInputType.name,
                  validator: Validators.username,
                ),
                SizedBox(height: 16.h),
                // Phone Field
                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم الهاتف',
                  prefixIcon: 'auth/phone',
                  prefixIconWidget: Icon(Icons.phone, color: Color(0xFF9CA3AF),),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'رقم الهاتف مطلوب';
                    }
                    if (!RegExp(r'^09[1-5]\d{7}$').hasMatch(value)) {
                      return 'رقم الهاتف غير صحيح';
                    }
                    return null;
                  },
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
                SizedBox(height: 16.h),
                // Confirm Password Field
                Obx(
                  () => _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'تأكيد كلمة المرور مطلوب';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 32.h),
                // Register Button
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.register(
                                _nameController.text,
                                _phoneController.text,
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
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      child: Text(
                        'تسجيل الدخول',
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
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: prefixIconWidget,
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
