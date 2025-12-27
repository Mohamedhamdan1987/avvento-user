import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';

enum ClientNavItem {
  home,
  cart,
  orders,
  account,
}

class ClientBottomNavBar extends StatelessWidget {
  final ClientNavItem currentIndex;
  final Function(ClientNavItem) onTap;

  const ClientBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86.h,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.borderLightGray,
            width: 0.761,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.753.h,
          left: 24.w,
          right: 24.w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: 'assets/svg/client/nav-bar/home.svg',
              label: 'الرئيسية',
              isActive: currentIndex == ClientNavItem.home,
              onTap: () => onTap(ClientNavItem.home),
            ),
            _buildNavItem(
              icon: 'assets/svg/client/nav-bar/cart.svg',
              label: 'السلة',
              isActive: currentIndex == ClientNavItem.cart,
              onTap: () => onTap(ClientNavItem.cart),
            ),
            _buildNavItem(
              icon: 'assets/svg/client/nav-bar/orders.svg',
              label: 'طلباتي',
              isActive: currentIndex == ClientNavItem.orders,
              onTap: () => onTap(ClientNavItem.orders),
            ),
            _buildNavItem(
              icon: 'assets/svg/client/nav-bar/account.svg',
              label: 'حسابي',
              isActive: currentIndex == ClientNavItem.account,
              onTap: () => onTap(ClientNavItem.account),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 35.988.w,
            height: 35.988.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: isActive ? AppColors.purple.withOpacity(0.1) : Colors.transparent,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 24.w,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  isActive ? AppColors.purple : AppColors.textPlaceholder,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.996.h),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.purple : AppColors.textPlaceholder,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

