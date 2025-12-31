import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String iconName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;

  const SvgIcon({
    super.key,
    required this.iconName,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain, this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ,
      child: SvgPicture.asset(
        iconName,
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit,
      ),
    );
  }
}










