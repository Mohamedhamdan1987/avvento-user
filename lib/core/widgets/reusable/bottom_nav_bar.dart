import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import 'svg_icon.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF3F4F6), width: 0.76.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            iconName: 'assets/svg/nav/home.svg',
            label: 'الرئيسية',
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            iconName: 'assets/svg/nav/list.svg',
            label: 'طلباتي',
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            iconName: 'assets/svg/nav/cart.svg',
            label: 'السلة',
            index: 2,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            iconName: 'assets/svg/nav/person.svg',
            label: 'حسابي',
            index: 3,
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconName,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 64.w,
        height: 64.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              iconName: iconName,
              width: 24.w,
              height: 24.h,
              color: isActive ? AppColors.primary : const Color(0xFF99A1AF),
            ),
            SizedBox(height: 4.h),
            Container(
              height: 4.h,
              width: 32.w,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isActive ? AppColors.primary : const Color(0xFF99A1AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
