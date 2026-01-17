import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class SupportMessageBubble extends StatelessWidget {
  final String text;
  final bool isFromSupport;
  final DateTime timestamp;
  final String Function(DateTime) onTimeFormat;

  const SupportMessageBubble({
    super.key,
    required this.text,
    required this.isFromSupport,
    required this.timestamp,
    required this.onTimeFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (isFromSupport) {
      // Support message (left side)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent,
              size: 16.sp,
              color: AppColors.purple,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.r),
                  topLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                  bottomLeft: Radius.circular(3.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    onTimeFormat(timestamp),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // User message (right side)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.r),
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(3.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    onTimeFormat(timestamp),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor, // Or better, slightly different shade
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 16.sp,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      );
    }
  }
}


