import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String? imagePath;
  final String? svgContent;
  final String title;
  final VoidCallback onTap;
  final double pullProgress;

  const CategoryCard({
    super.key,
    this.imagePath,
    this.svgContent,
    required this.title,
    required this.onTap,
    this.pullProgress = 0.0,
  }) : assert(imagePath != null || svgContent != null, 'Either imagePath or svgContent is required');

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = pullProgress.clamp(0.0, 1.0);
    final scale = 1.0 + (normalizedProgress * 0.04);

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 76.w,
          height: 100.h,
          padding: EdgeInsets.only(top: 8.h, left: 8.w, right: 8.w),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle().textColorMedium(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 8.h),
              if (svgContent != null && svgContent!.isNotEmpty)
                SvgPicture.string(
                  svgContent!,
                  width: 34.w,
                  height: 34.h,
                  placeholderBuilder: (_) => Icon(
                    Icons.image_outlined,
                    size: 28.w,
                    color: AppColors.purple.withOpacity(0.7),
                  ),
                )
              else
                Image.asset(
                  imagePath!,
                  // width: 32.w,
                  // height: 32.h,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
