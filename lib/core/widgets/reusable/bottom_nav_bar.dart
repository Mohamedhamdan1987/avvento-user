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
    return Container(
      height: 73.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.76.w,
          ),
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
    final inactiveColor = Theme.of(context).unselectedWidgetColor ?? const Color(0xFF99A1AF);
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
              color: isActive ? AppColors.primary : inactiveColor,
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
                color: isActive ? AppColors.primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
