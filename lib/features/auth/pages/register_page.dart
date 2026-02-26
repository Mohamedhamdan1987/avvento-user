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
  double? selectedLat;
  double? selectedLong;
  String? selectedLocationType;
  String? selectedNotes;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['address'] is String) {
      addressController.text = args['address'] as String;
    }
    if (args is Map) {
      final lat = args['lat'];
      final long = args['long'];
      selectedLat = lat is num ? lat.toDouble() : double.tryParse('$lat');
      selectedLong = long is num ? long.toDouble() : double.tryParse('$long');
      selectedLocationType = args['locationType']?.toString();
      selectedNotes = args['notes']?.toString();
    }
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: AppColors.drawerPurple),
      //   title: Text(
      //     'إنشاء حساب جديد',
      //     style: TextStyle(
      //       fontSize: 20.sp,
      //       fontWeight: FontWeight.bold,
      //       color: Theme.of(context).textTheme.titleLarge?.color,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
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
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'املأ البيانات التالية للتسجيل',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                // Name Field
                CustomTextField(
                  controller: nameController,
                  // label: 'الاسم الكامل',
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
                SizedBox(height: 16.h),
                // Username Field
                CustomTextField(
                  controller: usernameController,
                  // label: 'اسم المستخدم',
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
                SizedBox(height: 16.h),
                // Email Field
                CustomTextField(
                  controller: emailController,
                  // label: 'البريد الإلكتروني',
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
                SizedBox(height: 16.h),
                // Phone Field
                CustomTextField(
                  controller: phoneController,
                  // label: 'رقم الهاتف',
                  hint: 'أدخل رقم الهاتف',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  borderRadius: 16,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // Password Field
                CustomTextField(
                  controller: passwordController,
                  // label: 'كلمة المرور',
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
                SizedBox(height: 16.h),
                // Confirm Password Field
                CustomTextField(
                  controller: confirmPasswordController,
                  // label: 'تأكيد كلمة المرور',
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
                SizedBox(height: 16.h),
                // Address Field (Optional)
                CustomTextField(
                  controller: addressController,
                  label: 'العنوان (اختياري)',
                  hint: 'أدخل العنوان',
                  prefixIcon: Icons.location_on,
                  borderRadius: 16,
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
                      onTap: controller.isLoading
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
                                role: 'user',
                                address: addressController.text.trim(),
                                lat: selectedLat,
                                long: selectedLong,
                                locationType: selectedLocationType,
                                notes: selectedNotes,
                              );
                            },
                      isLoading: controller.isLoading,
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
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.login);
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
