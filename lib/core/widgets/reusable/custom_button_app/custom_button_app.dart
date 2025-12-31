import 'package:avvento/core/constants/app_colors.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CustomButtonApp extends StatefulWidget {
  const CustomButtonApp({
    Key? key,
    this.text,
    this.childWidget,
    this.onTap,
    this.icon,
    this.color = AppColors.primary,
    this.height,
    this.borderRadius,
    this.borderColor,
    this.iconColor,
    this.image,
    this.imageColor,
    this.fontSize,
    this.fontHeight,
    this.width,
    this.textStyle,
    this.mainAxisAlignment,
    this.padding,
    this.isFill = true,
    this.isEnable = true,
    this.isLoading = false,
    this.borderWidth,
    this.wrapContent = false,
  }) : super(key: key);

  final String? text;
  final Widget? childWidget;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment? mainAxisAlignment;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Widget? icon;
  final String? image;
  final Color? color;
  final Color? iconColor;
  final Color? imageColor;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? fontHeight;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  // final bool loading;
  final bool isFill;
  final bool isEnable;
  final bool isLoading;
  final bool wrapContent;

  @override
  State<CustomButtonApp> createState() => _CustomButtonAppState();
}

class _CustomButtonAppState extends State<CustomButtonApp> {
  @override
  Widget build(BuildContext context) {
    Widget button = ClipRRect(
      // borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
      child: Container(
        height: widget.height ?? 44.h,
        width: widget.width,
        child: OutlinedButton(
          onPressed: (widget.isLoading || !widget.isEnable)
              ? null
              : widget.onTap,
          style: OutlinedButton.styleFrom(
            side: widget.isFill
                ? BorderSide.none
                : BorderSide(
                    color: widget.borderColor ?? Color(0xFFD6D6D6),
                    width: widget.borderWidth ?? 1.w,
                  ),
            padding: widget.padding ?? EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.r),
            ),
            backgroundColor: widget.isFill
                ? (widget.isEnable ? widget.color : const Color(0xFFE0E0E0))
                : Colors.transparent,
          ),

          child: (widget.isLoading)
              ? CircularProgressIndicator(color: AppColors.primary,)
              : Row(
                  mainAxisAlignment:
                      widget.mainAxisAlignment ?? MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.icon != null && !widget.isLoading) widget.icon!,
                    if (widget.isLoading)
                      Padding(
                        padding: EdgeInsets.all(6.r),
                        child: CircularProgressIndicator(
                          color: widget.isFill
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 3),

                        child:
                            widget.childWidget ??
                            Text(
                              widget.text ?? '',
                              textAlign: TextAlign.center,
                              style:
                                  widget.textStyle ??
                                  TextStyle(
                                    height: widget.fontHeight,
                                    fontSize: widget.fontSize ?? 16.sp,
                                    color: widget.isFill
                                        ? (widget.isEnable
                                              ? Colors.white
                                              : const Color(0xFFACACAC))
                                        : AppColors.primary,
                                  )
                            ),
                      ),
                    if (widget.image != null && !widget.isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: SvgIcon(
                          iconName: widget.image!,
                          color: widget.imageColor,
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );

    if (widget.wrapContent) {
      return IntrinsicWidth(child: button);
    }

    return button;
  }
}
