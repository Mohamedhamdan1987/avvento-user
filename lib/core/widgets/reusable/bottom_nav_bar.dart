import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import 'svg_icon.dart';

class BottomNavItemModel {
  final String iconName;
  final String label;

  BottomNavItemModel({
    required this.iconName,
    required this.label,
  });
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItemModel> navItems;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.76.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildNavItem(
            context,
            iconName: item.iconName,
            label: item.label,
            index: index,
            isActive: currentIndex == index,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String iconName,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF99A1AF);
    // Use lighter primary color in dark theme for better contrast
    final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;
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
              color: isActive ? activeColor : inactiveColor,
            ),
            SizedBox(height: 4.h),
            Container(
              height: 4.h,
              width: 32.w,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
