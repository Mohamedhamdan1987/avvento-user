import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? prefixIconWidget;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.hint,
    this.label,
    this.prefixIcon,
    this.prefixIconWidget,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.onTap,
    this.fillColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1, this.borderColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? prefixIconWidget;
    if (widget.prefixIconWidget != null) {
      prefixIconWidget = widget.prefixIconWidget;
    } else if (widget.prefixIcon != null) {
      prefixIconWidget = Icon(
        widget.prefixIcon,
        color: Theme.of(context).hintColor,
        size: 20.sp,
      );
    }

    Widget? suffixIconWidget = widget.suffixIcon;
    if (widget.obscureText && widget.suffixIcon == null) {
      suffixIconWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).hintColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    final textField = TextFormField(
      onTap: widget.onTap,
      readOnly: widget.onTap != null,
      // enabled: widget.onTap == null, // إذا تم توفير onTap، اجعل الحقل غير قابل للتحريرق
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      style: TextStyle(
        fontSize: 14.sp,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontFamily: 'IBMPlexSansArabic',
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).hintColor,
          fontFamily: 'IBMPlexSansArabic',
        ),
        prefixIcon: prefixIconWidget,
        suffixIcon: suffixIconWidget,
        filled: true,
        fillColor: widget.fillColor ?? Theme.of(context).cardColor,
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: widget.borderColor != null
              ? BorderSide(color: widget.borderColor!)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: widget.borderColor != null
              ? BorderSide(color: widget.borderColor!)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: BorderSide(
              color: widget.borderColor ?? AppColors.purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          textField,
        ],
      );
    }

    return textField;
  }
}
