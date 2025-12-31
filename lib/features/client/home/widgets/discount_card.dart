import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum DiscountCardType { purple, black, white }

class DiscountCard extends StatelessWidget {
  final DiscountCardType type;
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const DiscountCard({
    super.key,
    required this.type,
    this.imageUrl,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    
    switch (type) {
      case DiscountCardType.purple:
        bgColor = AppColors.purple;
        textColor = Colors.white;
        break;
      case DiscountCardType.black:
        bgColor = Colors.black;
        textColor = Colors.white;
        break;
      case DiscountCardType.white:
        bgColor = Colors.white;
        textColor = AppColors.textDark;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: type == DiscountCardType.white 
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
              if (imageUrl != null)
                Positioned.fill(
                  child: imageUrl!.startsWith('http') 
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.2),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.borderGray,
                            child: const Icon(Icons.image),
                          ),
                        )
                      : Image.asset(
                          imageUrl!,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.2),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.borderGray,
                            child: const Icon(Icons.image),
                          ),
                        ),
                ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle().textColorBold(color: textColor, fontSize: 15),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle().textColorLight(color: textColor.withOpacity(0.8), fontSize: 12),
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
