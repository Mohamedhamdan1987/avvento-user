import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isLast;

  const OrderStepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16.w,
      children: [
        Column(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF9FAFB),
                  width: 3.8.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF99A1AF),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 68.h,
                // margin: EdgeInsets.only(top: 8.h),
                color: const Color(0xFFE5E7EB),
              ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF101828),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6A7282),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
