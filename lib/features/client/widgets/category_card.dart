import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';

class CategoryCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 79.195.w,
        height: 127.992.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.lightBackground,
            width: 0.761,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 20,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 9.99.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.99.w),
              child: Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4.5.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(7.11.w),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: SvgPicture.asset(
                      iconPath,
                      width: 63.462.w,
                      height: 87.991.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

