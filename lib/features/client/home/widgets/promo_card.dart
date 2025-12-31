import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PromoCard extends StatelessWidget {
  final String imageUrl;
  final String restaurantName;
  final double rating;
  final String distance;
  final String deliveryFee;
  final bool hasFreeDelivery;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const PromoCard({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    required this.rating,
    required this.distance,
    required this.deliveryFee,
    required this.hasFreeDelivery,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.borderGray,
                              child: const Icon(Icons.image),
                            ),
                          )
                        : Image.asset(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.borderGray,
                              child: const Icon(Icons.image),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/svg/client/home/favorite.svg',
                          colorFilter: ColorFilter.mode(
                            isFavorite ? AppColors.notificationRed : Colors.grey,
                            BlendMode.srcIn,
                          ),
                          width: 16.w,
                          height: 16.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(rating.toString(), style: const TextStyle().textColorLight(fontSize: 12)),
                        ],
                      ),
                      Text(
                        restaurantName,
                        style: const TextStyle().textColorBold(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$distance • ${hasFreeDelivery ? "توصيل مجاني" : "توصيل $deliveryFee"}',
                        style: const TextStyle().textColorLight(fontSize: 12),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.asset(
                        'assets/svg/client/home/truck.svg',
                        width: 14.w,
                        height: 14.h,
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                      ),
                    ],
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
