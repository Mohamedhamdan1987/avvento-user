import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIconButtonApp extends StatefulWidget {
  final String? text;
  final Widget? childWidget;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final double? radius;
  final Color? borderColor;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  const CustomIconButtonApp({
    Key? key,
    this.text,
    this.childWidget,
    this.onTap, this.height, this.width, this.radius, this.borderColor, this.color, this.padding, this.textStyle,
  }) : super(key: key);


  @override
  State<CustomIconButtonApp> createState() => _CustomIconButtonAppState();
}

class _CustomIconButtonAppState extends State<CustomIconButtonApp> {
  @override
  Widget build(BuildContext context) {
    return CustomButtonApp(
      text: widget.text,
      onTap: widget.onTap,
      height: widget.height ?? 44,
      width: widget.width ?? 44,
      borderRadius: widget.radius ?? 100.r,
      isFill: widget.color != null ? true:  false,
      borderColor:  widget.borderColor?? Colors.transparent,
      childWidget: widget.childWidget,
      color: widget.color ?? Colors.transparent,
      padding: widget.padding,
        textStyle: widget.textStyle,

    );
  }
}