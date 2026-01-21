import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../../../core/widgets/reusable/custom_text_field.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.drawerPurple),
        title: Text(
          'إعادة تعيين كلمة المرور',
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
          child: Form(
            key: _formKey,
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
                      Icons.lock_reset,
                      size: 50.sp,
                      color: AppColors.drawerPurple,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                // Title
                Text(
                  'إعادة تعيين كلمة المرور',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'أدخل رمز التحقق المرسل إلى',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
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
                  child: CustomTextField(
                    controller: _newPasswordController,
                    label: 'كلمة المرور الجديدة',
                    hint: 'أدخل كلمة المرور الجديدة',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الجديدة';
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
                  child: CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    borderRadius: 16,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != _newPasswordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 32.h),
                // Reset Button
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
                      text: 'إعادة تعيين كلمة المرور',
                      color: AppColors.drawerPurple,
                      onTap:  controller.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final otp = _getOtpCode();
                                if (otp.length != 6) {
                                  showSnackBar(
                                    title: 'خطأ',
                                    message: 'يرجى إدخال رمز التحقق كاملاً',
                                    isError: true,
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
                      isLoading:  controller.isLoading,
                      borderRadius: 16,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
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
          color: Theme.of(context).textTheme.headlineMedium?.color,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1.w,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.drawerPurple,
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
