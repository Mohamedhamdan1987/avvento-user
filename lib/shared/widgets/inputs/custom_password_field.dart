import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_extensions.dart';
import 'custom_text_field.dart';

class CustomPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;

  const CustomPasswordField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.prefixIcon,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 8.0,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hint: widget.hint,
      initialValue: widget.initialValue,
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      enabled: widget.enabled,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      prefixIcon: widget.prefixIcon,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
          size: 20.sp,
        ),
        onPressed: _toggleObscureText,
      ),
      contentPadding: widget.contentPadding,
      fillColor: widget.fillColor,
      borderColor: widget.borderColor,
      borderRadius: widget.borderRadius,
    );
  }
}

