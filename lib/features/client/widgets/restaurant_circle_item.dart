import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';

class RestaurantCircleItem extends StatelessWidget {
  final String imageUrl;
  final String restaurantName;
  final VoidCallback? onTap;

  const RestaurantCircleItem({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 69.99.w,
        child: Column(
          children: [
            Container(
              width: 69.99.w,
              height: 69.99.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderLightGray,
                  width: 0.761,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(4.757.w),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.borderGray,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.borderGray,
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 7.98.h),
            SizedBox(
              height: 16.495.h,
              child: Text(
                restaurantName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

