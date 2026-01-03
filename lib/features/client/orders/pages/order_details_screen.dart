import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context),
            
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Card
                      _buildOrderCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 82.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 32.w),
              Text(
                'طلباتي',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Color(0xFF101828),
                ),
              ),
              CustomIconButtonApp(
                width: 32.w,
                height: 32.h,
                radius: 100.r,
                color: Colors.transparent,
                onTap: () {
                  Navigator.pop(context);
                },
                childWidget: SvgIcon(
                  iconName: 'assets/svg/arrow-right.svg',
                  width: 20.w,
                  height: 20.h,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar
          _buildProgressBar(),
          
          SizedBox(height: 40.h),
          
          // Order Header
          _buildOrderHeader(),
          
          SizedBox(height: 24.h),
          
          // Estimated Time Section
          _buildEstimatedTimeSection(),
          
          SizedBox(height: 24.h),
          
          // Order Items
          _buildOrderItems(),
          
          SizedBox(height: 24.h),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF7F22FE),
                borderRadius: BorderRadius.circular(3.r),
                border: BorderDirectional(
                  end: BorderSide(
                    color: Colors.white,
                    width: 0.76.w,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF7F22FE),
                borderRadius: BorderRadius.circular(3.r),
                border: BorderDirectional(
                  end: BorderSide(
                    color: Colors.white,
                    width: 0.76.w,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Order Number
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '#${order['id']}',
            style: TextStyle().textColorBold(
              fontSize: 12.sp,
              color: Color(0xFF99A1AF),
            ),
          ),
        ),
        
        // Restaurant Info
        Expanded(
          child: Row(
            children: [
              // Restaurant Image
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Color(0xFFF3F4F6),
                    width: 0.76.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: order['restaurantImage'] ?? '',
                    width: 56.w,
                    height: 56.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Color(0xFFF9FAFB),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Restaurant Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['restaurantName'] ?? '',
                      style: TextStyle().textColorBold(
                        fontSize: 18.sp,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: Color(0xFF7F22FE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'جاري تحضير طلبك',
                            style: TextStyle().textColorBold(
                              fontSize: 12.sp,
                              color: Color(0xFF7F22FE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedTimeSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: SvgIcon(
                iconName: 'assets/svg/client/orders/clock_icon.svg',
                width: 24.w,
                height: 24.h,
                color: Color(0xFF101828),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Time Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت الوصول المتوقع',
                  style: TextStyle().textColorNormal(
                    fontSize: 12.sp,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  order['estimatedTime'] ?? '12:45 م',
                  style: TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يصل خلال ${order['timeRemaining'] ?? '15-20 دقيقة'}',
                  style: TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: Color(0xFF00A63E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order['items'] ?? '',
          style: TextStyle().textColorNormal(
            fontSize: 14.sp,
            color: Color(0xFF4A5565),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'الإجمالي: ${order['price']} د.ل',
          style: TextStyle().textColorNormal(
            fontSize: 12.sp,
            color: Color(0xFF99A1AF),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Support Button
        Expanded(
          child: CustomButtonApp(
            text: 'الدعم',
            onTap: () {
              // Handle support
            },
            height: 48.h,
            borderRadius: 14.r,
            isFill: false,
            borderColor: Color(0xFFE5E7EB),
            borderWidth: 0.76.w,
            color: Colors.white,
            textStyle: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: Color(0xFF101828),
            ),
            childWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(
                  iconName: 'assets/svg/client/orders/support_icon.svg',
                  width: 16.w,
                  height: 16.h,
                  color: Color(0xFF101828),
                ),
                SizedBox(width: 8.w),
                Text(
                  'الدعم',
                  style: TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Color(0xFF101828),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Track Order Button
        Expanded(
          flex: 2,
          child: CustomButtonApp(
            text: 'تتبع الطلب',
            onTap: () {
              // Handle track order
            },
            height: 48.h,
            borderRadius: 14.r,
            color: Color(0xF07F22FE).withOpacity(0.94),
            textStyle: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

