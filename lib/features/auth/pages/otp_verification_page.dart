import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phone;
  final bool isFromRegister;

  const OtpVerificationPage({
    super.key,
    required this.phone,
    this.isFromRegister = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.drawerPurple),
        title: Text(
          'التحقق من الرمز',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),
              // Icon
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
                    Icons.message_outlined,
                    size: 50.sp,
                    color: AppColors.drawerPurple,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'أدخل رمز التحقق',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'تم إرسال رمز التحقق إلى ${widget.phone}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              // OTP Field
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: TextStyle(
                    fontSize: 24.sp,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      fontSize: 24.sp,
                      letterSpacing: 8,
                      color: Theme.of(context).hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor, // Or specific light/dark sensitive color
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Verify Button
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
                    text: 'تحقق',
                    color: AppColors.drawerPurple,
                    onTap: controller.isLoading
                        ? null
                        : () {
                            if (otpController.text.length != 6) {
                              showSnackBar(
                                title: 'خطأ',
                                message: 'يرجى إدخال رمز التحقق كاملاً',
                                isError: true,
                              );
                              return;
                            }
                            // TODO: Implement OTP verification
                            showSnackBar(
                              title: 'نجح',
                              message: 'تم التحقق بنجاح',
                              isSuccess: true,
                            );
                          },
                    isLoading: controller.isLoading,
                    borderRadius: 16,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Resend Button
              TextButton(
                onPressed: () {
                  // TODO: Resend OTP
                  showSnackBar(
                    title: 'نجح',
                    message: 'تم إعادة إرسال الرمز',
                    isSuccess: true,
                  );
                },
                child: Text(
                  'إعادة إرسال الرمز',
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
    );
  }
}
