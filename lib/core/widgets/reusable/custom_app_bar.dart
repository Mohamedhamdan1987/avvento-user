import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onLeadingPressed;
  final Color backgroundColor;
  final Color? contentColor;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onLeadingPressed,
    this.backgroundColor = Colors.transparent,
    this.contentColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveContentColor = contentColor ?? Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textDark;
    
    return AppBar(
      backgroundColor: backgroundColor == Colors.transparent 
          ? (Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor)
          : backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: _buildLeading(context, effectiveContentColor),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStyle(
                    color: effectiveContentColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                )
              : null),
      actions: actions,
      iconTheme: IconThemeData(color: effectiveContentColor),
      actionsIconTheme: IconThemeData(color: effectiveContentColor),
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context, Color color) {
    if (leading != null) return leading;
    if (!showBackButton) return null;

    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;


    if (!canPop) return null;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: CustomIconButtonApp(
        onTap: onLeadingPressed ?? () => Navigator.of(context).pop(),
        childWidget: SvgIcon(
          iconName: 'assets/svg/arrow-right.svg',
          width: 20.w,
          height: 20.h,
          color: color,
        ),
      ),
    );
    // return IconButton(
    //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
    //   onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
    //   color: contentColor,
    //   iconSize: 20.sp,
    // );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height + (bottom?.preferredSize.height ?? 0));
}
