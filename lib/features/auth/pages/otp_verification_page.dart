import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/reusable/svg_icon.dart';
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

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with WidgetsBindingObserver {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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
    // Focus first field on init
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
      // Auto submit after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        _submitOtp();
      });
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
        // Auto submit if all fields are filled
        _submitOtp();
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

  void _submitOtp() {
    final otp = _getOtpCode();
    if (otp.length == 6) {
      controller.verifyOtp(widget.phone, otp);
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
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
                'التحقق من رقم الهاتف',
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
                widget.phone,
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
              SizedBox(height: 24.h),
              // Verify Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          final otp = _getOtpCode();
                          if (otp.length == 6) {
                            controller.verifyOtp(widget.phone, otp);
                          } else {
                            Get.snackbar(
                              'خطأ',
                              'يرجى إدخال رمز التحقق كاملاً',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white,
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
                          'تحقق',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16.h),
              // Resend OTP
              TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () {
                        // TODO: Implement resend OTP
                        Get.snackbar(
                          'معلومة',
                          'سيتم إعادة إرسال رمز التحقق',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                child: Text(
                  'إعادة إرسال الرمز',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
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
          // Custom formatter to handle paste
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
          // Select all text when tapping
          _otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index].text.length,
          );
          // Check clipboard when user taps on any field
          _checkClipboard();
        },
        onSubmitted: (_) {
          if (index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else {
            _submitOtp();
          }
        },
      ),
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

