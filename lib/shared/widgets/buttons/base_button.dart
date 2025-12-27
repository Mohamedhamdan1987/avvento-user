import 'package:flutter/material.dart';

abstract class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final Widget? icon;
  final IconPosition iconPosition;

  const BaseButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.icon,
    this.iconPosition = IconPosition.start,
  });

  @protected
  Widget buildContent(BuildContext context);
}

enum IconPosition {
  start,
  end,
}

