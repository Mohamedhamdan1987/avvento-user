import 'package:avvento/core/widgets/reusable/svg_icon.dart';
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
  final Color? color  ;

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
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        // width: 345,
        // height: 216,
        padding: const EdgeInsets.only(
          top: 12.76,
          left: 12.76,
          right: 12.76,
          bottom: 0.76,
        ),
        decoration: ShapeDecoration(
          color: color ?? (isDark ? const Color(0xFF111827) : Colors.white),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.76,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.10),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16.r)),
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.borderGray,
                                  child: const Icon(Icons.image),
                                ),
                          )
                        : Image.asset(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
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
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.50)
                              : Colors.white.withValues(alpha: 0.68),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            (isFavorite) ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                          color:  AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 12.h,
                    end: 12.w,
                    child: Container(
                      width: 47.07,
                      height: 22.99,
                      alignment: Alignment.center,
                      padding: EdgeInsetsDirectional.only(end: 2, bottom: 2),
                      decoration: ShapeDecoration(
                        color: isDark ? const Color(0xFF111827) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.30)
                                : const Color(0x19000000),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                            spreadRadius: -1,
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.30)
                                : const Color(0x19000000),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(iconName: "assets/svg/client/home/star.svg"),
                          SizedBox(width: 4.w),
                          Text(
                            rating.toString(),
                            style: const TextStyle().textColorBold(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).textTheme.labelLarge?.color,
                            ),
                          ),
                        ],
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
                      Text(
                        restaurantName,
                        style: const TextStyle().textColorBold(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      if (hasFreeDelivery)
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                'عرض التوصيل مجاني',
                                style: const TextStyle().textColorSemiBold(
                                  fontSize: 10,
                                  color: Color(0xFF00A63E),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            SvgIcon(
                              iconName:
                                  "assets/svg/client/home/free_delivery.svg",
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 16.w,
                    children: [
                      Text(
                        'التوصيل: ${deliveryFee} دينار',

                        style: const TextStyle().textColorMedium(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        'المسافة: ${distance}',

                        style: const TextStyle().textColorSemiBold(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
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
