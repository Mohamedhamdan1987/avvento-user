// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../constants/app_colors.dart';
//
// class AppTextStyles {
//   static TextStyle get h4 => TextStyle(
//         fontSize: 20.sp,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textDark,
//         fontFamily: 'IBMPlexSansArabic',
//       );
//
//   static TextStyle get h5 => TextStyle(
//         fontSize: 15.sp,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textDark,
//         fontFamily: 'IBMPlexSansArabic',
//       );
//
//   static TextStyle get bodyLarge => TextStyle(
//         fontSize: 16.sp,
//         fontWeight: FontWeight.normal,
//         color: AppColors.textDark,
//         fontFamily: 'IBMPlexSansArabic',
//       );
//
//   static TextStyle get bodyMedium => TextStyle(
//         fontSize: 14.sp,
//         fontWeight: FontWeight.normal,
//         color: AppColors.textDark,
//         fontFamily: 'IBMPlexSansArabic',
//       );
//
//   static TextStyle get bodySmall => TextStyle(
//         fontSize: 12.sp,
//         fontWeight: FontWeight.normal,
//         color: AppColors.textLight,
//         fontFamily: 'IBMPlexSansArabic',
//       );
// }


import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  TextStyle textColorLight({Color? color, double? fontSize, double? height}) => copyWith(
    color: color,
    height: height,
    fontFamily: 'IBMPlexSansArabic',
    fontSize: fontSize,
    fontWeight: FontWeight.w300,
  );

  TextStyle textColorNormal({Color? color, double? fontSize, double? height}) => copyWith(
      color: color,
      height: height,
      fontFamily: 'IBMPlexSansArabic',
      fontWeight: FontWeight.w400,
      fontSize: fontSize);

  TextStyle textColorMedium({Color? color, double? fontSize, double? height}) => copyWith(
    color: color,
    height: height,
    fontFamily: 'IBMPlexSansArabic',
    fontSize: fontSize ?? 13,
    fontWeight: FontWeight.w500,
  );
  TextStyle textColorSemiBold({Color? color, double? fontSize, double? height}) => copyWith(
    color: color,
    height: height,
    fontFamily: 'IBMPlexSansArabic',
    fontSize: fontSize ?? 13,
    fontWeight: FontWeight.w600,
  );

  TextStyle textColorBold({Color? color, double? fontSize, double? height}) => copyWith(
      color: color,
      height: height,
      fontFamily: 'IBMPlexSansArabic',
      // fontFamily: 'Allan',
      fontWeight: FontWeight.w700,
      fontSize: fontSize);

  TextStyle textColorBlack({Color? color, double? fontSize, double? height}) => copyWith(
      color: color,
      height: height,
      fontFamily: 'IBMPlexSansArabic',
      fontWeight: FontWeight.w900,
      fontSize: fontSize);
}
