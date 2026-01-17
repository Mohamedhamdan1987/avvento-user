import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: Colors.white,
        background: Colors.white,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error, width: 2.w),
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF6A7282),
          fontFamily: 'IBMPlexSansArabic',
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF99A1AF),
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
        displayMedium: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
        displaySmall: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
        headlineLarge: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        headlineMedium: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        headlineSmall: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        titleLarge: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        titleMedium: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        titleSmall: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        bodyLarge: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          fontFamily: 'IBMPlexSansArabic',
        ),
        bodyMedium: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          fontFamily: 'IBMPlexSansArabic',
        ),
        bodySmall: TextStyle(
          color: const Color(0xFF6A7282),
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          fontFamily: 'IBMPlexSansArabic',
        ),
        labelLarge: TextStyle(
          color: const Color(0xFF101828),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'IBMPlexSansArabic',
        ),
        labelMedium: TextStyle(
          color: const Color(0xFF6A7282),
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'IBMPlexSansArabic',
        ),
        labelSmall: TextStyle(
          color: const Color(0xFF6A7282),
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'IBMPlexSansArabic',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF111827), // Dark background
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: Color(0xFF1F2937), // Dark surface
        background: Color(0xFF111827),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F2937),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error, width: 2.w),
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontFamily: 'IBMPlexSansArabic',
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF6B7280),
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        titleSmall: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBMPlexSansArabic',
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          fontFamily: 'IBMPlexSansArabic',
        ),
        bodyMedium: TextStyle(
          color: const Color(0xFFD1D5DB),
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          fontFamily: 'IBMPlexSansArabic',
        ),
        bodySmall: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          fontFamily: 'IBMPlexSansArabic',
        ),
        labelLarge: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'IBMPlexSansArabic',
        ),
        labelMedium: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'IBMPlexSansArabic',
        ),
        labelSmall: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF374151),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'IBMPlexSansArabic',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
