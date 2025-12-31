import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import 'svg_icon.dart';

class StatCard extends StatelessWidget {
  final int count;
  final String title;
  final String subtitle;
  final String iconName;
  final List<Color> gradientColors;
  final Color textColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.count,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.gradientColors,
    this.textColor = AppColors.textPrimary,
    this.iconBackgroundColor = Colors.white, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Container(
        // height: 126.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.1),
              blurRadius: 15.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -32.w,
              bottom: -32.h,
              child: Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: SvgIcon(
                          iconName: iconName,
                          width: 20.w,
                          height: 20.h,
                          color: textColor,
                          padding: 10.r,
                        ),
                      ),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
