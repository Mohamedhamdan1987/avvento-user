import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';

class PromoCard extends StatelessWidget {
  final String imageUrl;
  final String restaurantName;
  final double rating;
  final String distance;
  final String deliveryFee;
  final bool hasFreeDelivery;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PromoCard({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    required this.rating,
    required this.distance,
    required this.deliveryFee,
    this.hasFreeDelivery = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 345.w,
        height: 216.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.borderE5,
            width: 0.761,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.761.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with rating and favorite
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 143.999.h,
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
                  // Favorite button
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 31.992.w,
                        height: 31.992.h,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.68),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.2),
                            width: 0.761,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/svg/client/home/favorite.svg',
                            width: 15.996.w,
                            height: 15.996.h,
                            colorFilter: ColorFilter.mode(
                              isFavorite ? AppColors.notificationRed : AppColors.textPlaceholder,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    bottom: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.992.w,
                        vertical: 0.h,
                      ),
                      height: 22.989.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(width: 3.996.w),
                          SvgPicture.asset(
                            'assets/svg/client/home/star.svg',
                            width: 12.w,
                            height: 12.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Restaurant info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Free delivery badge
                  if (hasFreeDelivery)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.992.w,
                        vertical: 0.h,
                      ),
                      height: 23.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/client/home/truck.svg',
                            width: 12.w,
                            height: 12.h,
                            colorFilter: const ColorFilter.mode(
                              AppColors.successGreen,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'عرض التوصيل مجاني',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Restaurant name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          restaurantName,
                          style: AppTextStyles.h6.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'المسافة: $distance',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            SvgPicture.asset(
                              'assets/svg/client/home/location.svg',
                              width: 10.w,
                              height: 10.h,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'التوصيل: $deliveryFee دينار',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

