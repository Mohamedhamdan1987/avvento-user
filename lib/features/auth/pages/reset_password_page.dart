import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/reusable/svg_icon.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userName;

  const ResetPasswordPage({
    super.key,
    required this.userName,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthController controller = Get.find<AuthController>();
  String? _lastClipboardValue;
  Timer? _clipboardCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkClipboard();
    // Start periodic clipboard check (every 1 second)
    _clipboardCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkClipboard();
    });
    // Focus first OTP field on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check clipboard when app resumes (user returns to app)
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!.trim();
        // Only process if clipboard value changed and contains 6 digits
        if (text != _lastClipboardValue && RegExp(r'^\d{6}$').hasMatch(text)) {
          _lastClipboardValue = text;
          _pasteOtp(text);
        }
      }
    } catch (e) {
      // Ignore clipboard errors
    }
  }

  void _pasteOtp(String otp, {int? startIndex}) {
    final start = startIndex ?? 0;
    for (int i = 0; i < 6 && (i + start) < 6 && i < otp.length; i++) {
      _otpControllers[i + start].text = otp[i];
    }
    // Focus on last field after pasting
    if (otp.length == 6 && start == 0) {
      _focusNodes[5].requestFocus();
    } else if (otp.length < 6 || start > 0) {
      // Focus on next empty field
      final nextIndex = (start + otp.length).clamp(0, 5);
      if (nextIndex < 6) {
        _focusNodes[nextIndex].requestFocus();
      }
    }
  }

  void _onOtpChanged(int index, String value) {
    // Note: Paste handling is done in _OtpPasteFormatter
    // This only handles single character input
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field - unfocus
        _focusNodes[index].unfocus();
      }
    } else {
      // Move to previous field on backspace
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardCheckTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF1F2937),
            size: 20.w,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                // Logo
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
                  'إعادة تعيين كلمة المرور',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    fontFamily: "IBMPlexSansArabic",
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'أدخل رمز التحقق المرسل إلى',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => _buildOtpField(index),
                  ),
                ),
                SizedBox(height: 32.h),
                // New Password Field
                Obx(
                  () => _buildTextField(
                    controller: _newPasswordController,
                    label: 'كلمة المرور الجديدة',
                    hint: 'أدخل كلمة المرور الجديدة',
                    prefixIconWidget: Icon(Icons.lock, color: Color(0xFF9CA3AF)),
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
                    prefixIconWidget: Icon(Icons.lock, color: Color(0xFF9CA3AF)),
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
                      if (value != _newPasswordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 32.h),
                // Reset Button
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final otp = _getOtpCode();
                              if (otp.length != 6) {
                                Get.snackbar(
                                  'خطأ',
                                  'يرجى إدخال رمز التحقق كاملاً',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.error,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              controller.resetPassword(
                                widget.userName,
                                otp,
                                _newPasswordController.text,
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
                            'إعادة تعيين كلمة المرور',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50.w,
      height: 60.h,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          counterText: '',
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
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2.w,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1.w,
            ),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _OtpPasteFormatter(
            fieldIndex: index,
            onPaste: (String pastedText, int fieldIndex) {
              if (RegExp(r'^\d{6}$').hasMatch(pastedText.trim())) {
                _pasteOtp(pastedText.trim(), startIndex: fieldIndex);
              }
            },
          ),
        ],
        onChanged: (value) => _onOtpChanged(index, value),
        onTap: () {
          _otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index].text.length,
          );
          _checkClipboard();
        },
        onSubmitted: (_) {
          if (index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
              child: prefixIconWidget,
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

// Custom TextInputFormatter to handle paste events
class _OtpPasteFormatter extends TextInputFormatter {
  final Function(String, int) onPaste;
  final int fieldIndex;

  _OtpPasteFormatter({
    required this.onPaste,
    required this.fieldIndex,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is longer than 1 character, it's likely a paste
    if (newValue.text.length > 1) {
      final pastedText = newValue.text.trim();
      // Check if it's a valid 6-digit OTP
      if (RegExp(r'^\d{6}$').hasMatch(pastedText)) {
        // Trigger paste handler with field index
        onPaste(pastedText, fieldIndex);
        // Return value with first character to fill current field
        return TextEditingValue(
          text: pastedText[0],
          selection: TextSelection.collapsed(offset: 1),
        );
      } else if (pastedText.length > 1) {
        // If it's not 6 digits but has multiple characters, take only first digit
        return TextEditingValue(
          text: pastedText[0],
          selection: TextSelection.collapsed(offset: 1),
        );
      }
    }
    // For single character input, allow normal behavior
    return newValue;
  }
}

