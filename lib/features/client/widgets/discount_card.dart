import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';

enum DiscountCardType {
  purple,
  black,
  white,
}

class DiscountCard extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final DiscountCardType type;
  final VoidCallback? onTap;

  const DiscountCard({
    super.key,
    this.imageUrl,
    this.title,
    this.subtitle,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    List<BoxShadow> shadows;

    switch (type) {
      case DiscountCardType.purple:
        backgroundColor = const Color(0xFF8E51FF);
        textColor = AppColors.white;
        shadows = [
          BoxShadow(
            color: const Color(0xFFDDD6FF),
            offset: const Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0xFFDDD6FF),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ];
        break;
      case DiscountCardType.black:
        backgroundColor = AppColors.textDark;
        textColor = AppColors.white;
        shadows = [
          BoxShadow(
            color: AppColors.borderGray,
            offset: const Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: AppColors.borderGray,
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ];
        break;
      case DiscountCardType.white:
        backgroundColor = AppColors.white;
        textColor = AppColors.textDark;
        shadows = [
          BoxShadow(
            color: const Color(0xFFFFD6A7),
            offset: const Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0xFFFFD6A7),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ];
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 144.998.w,
        height: 175.991.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: shadows,
        ),
        child: Stack(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: backgroundColor,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            if (type == DiscountCardType.black && imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            if (type == DiscountCardType.white && imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: AppColors.white.withOpacity(0.87),
                ),
              ),
            // Blur effect for purple and white
            if ((type == DiscountCardType.purple || type == DiscountCardType.white) && imageUrl != null)
              Positioned(
                left: -40.w,
                top: -40.h,
                child: Container(
                  width: 127.992.w,
                  height: 127.992.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withOpacity(0.2),
                  ),
                ),
              ),
            // Content
            if (title != null || subtitle != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 12.h,
                    left: 12.w,
                    right: 12.w,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppTextStyles.h4.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.6,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

