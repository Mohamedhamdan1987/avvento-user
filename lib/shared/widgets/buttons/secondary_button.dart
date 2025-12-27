import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';
import 'base_button.dart';

class SecondaryButton extends BaseButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.isEnabled = true,
    super.width,
    super.height = 48.0,
    super.padding,
    super.textColor = AppColors.textPrimary,
    super.borderRadius = 8.0,
    super.icon,
    super.iconPosition,
  }) : super(
          backgroundColor: Colors.transparent,
        );

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 48.h;
    final effectiveWidth = width;
    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 24.w);

    Widget buttonContent = buildContent(context);

    Widget button = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isEnabled && !isLoading
              ? AppColors.border
              : AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: Container(
            padding: effectivePadding,
            alignment: Alignment.center,
            child: buttonContent,
          ),
        ),
      ),
    );

    return button;
  }

  @override
  Widget buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? AppColors.textPrimary,
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: AppTextStyles.buttonMedium.copyWith(
        color: isEnabled
            ? (textColor ?? AppColors.textPrimary)
            : AppColors.textDisabled,
      ),
      textAlign: TextAlign.center,
    );

    if (icon != null) {
      if (iconPosition == IconPosition.start) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon!,
            SizedBox(width: 8.w),
            textWidget,
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textWidget,
            SizedBox(width: 8.w),
            icon!,
          ],
        );
      }
    }

    return textWidget;
  }
}

