import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'meal_details_dialog.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Top Header Section with Background Image
            _buildHeaderSection(context),
            SizedBox(height: 60.h),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Stats Row
                    _buildStatsRow(),

                    SizedBox(height: 14.h),

                    // Today's Offers Section
                    _buildTodaysOffersSection(),

                    SizedBox(height: 32.h),

                    // Browse Menu Section
                    _buildBrowseMenuSection(),

                    SizedBox(height: 32.h),

                    // All Items Section
                    _buildAllItemsSection(context),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Image
        Container(
          height: 280.h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r)),
            child: CachedNetworkImage(
              imageUrl:
                  "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 280.h,
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          height: 280.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.1),
                Color(0xFF101828).withOpacity(0.8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Navigation Buttons (Top Right in RTL = Top Left visually)
        Positioned(
          width: MediaQuery.of(context).size.width,
          top: 48.h,
          // right: 24.w,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                CustomIconButtonApp(
                  width: 40.w,
                  height: 40.h,
                  radius: 100.r,
                  color: Color(0xB37F22FE),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  childWidget: SvgIcon(
                    iconName: 'assets/svg/arrow-right.svg',
                    width: 20.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                CustomIconButtonApp(
                  width: 40.w,
                  height: 40.h,
                  radius: 100.r,
                  color: Color(0x997F22FE),
                  onTap: () {},
                  childWidget: SvgIcon(
                    iconName: 'assets/svg/search-icon.svg',
                    width: 20.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                CustomIconButtonApp(
                  width: 40.w,
                  height: 40.h,
                  radius: 100.r,
                  color: Color(0x997F22FE),
                  onTap: () {},
                  childWidget: SvgIcon(
                    iconName: 'assets/svg/share_icon.svg',
                    width: 20.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Restaurant Name and Description (Bottom Right in RTL)
        Positioned(
          bottom: 16.h,
          right: 24.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'مطعم الكوخ',
                style: TextStyle().textColorBold(
                  fontSize: 25.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'أفضل المأكولات الشامية',
                style: TextStyle().textColorMedium(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Profile Picture Overlapping
        _buildProfilePicture(),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return PositionedDirectional(
      bottom: -50.h,
      end: 43.w,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.w),
        ),
        child: Container(
          width: 98.w,
          height: 98.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF7F22FE), width: 3.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl:
                  "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=200",
              width: 98.w,
              height: 98.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 34.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Color(0x12D9D9D9),
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: Color(0x33E3E3E3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: 'assets/svg/client/restaurant_details/clock.svg',
            value: '25 دقيقة',
            label: 'التحضير',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            icon: 'assets/svg/client/restaurant_details/location.svg',
            value: '1.2 كم',
            label: 'المسافة',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            icon: 'assets/svg/client/restaurant_details/bike.svg',
            value: '10',
            label: 'التوصيل',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            icon: 'assets/svg/client/restaurant_details/inactive_star_icon.svg',
            value: '4.8',
            label: 'التقييم',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        SvgIcon(
          iconName: icon,
          width: 16.w,
          height: 16.h,
          color: Color(0xFF101828),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Color(0xFF101828),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Color(0xFF99A1AF),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysOffersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            spacing: 8.w,
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/flame_icon.svg',
                width: 20.w,
                height: 20.h,
                color: Color(0xFF7F22FE),
              ),
              Text(
                'عروضنا لهذا اليوم',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Offer Card
          Container(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 12.h,
              bottom: 24.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Color(0xFFF3F4F6), width: 0.76.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Offer Image
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 96.w,
                        height: 96.h,
                        decoration: BoxDecoration(
                          color: Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
                          width: 96.w,
                          height: 96.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Add Button Overlay
                    Positioned(
                      bottom: -13.h,
                      child: CustomIconButtonApp(
                        width: 32.w,
                        height: 32.h,
                        radius: 100.r,
                        color: Color(0xFF101828),
                        onTap: () {},
                        childWidget: SvgIcon(
                          iconName: 'assets/svg/plus-solid.svg',
                          width: 16.w,
                          height: 16.h,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 12.w),

                // Offer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عرض وجبة عائلية',
                        style: TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'شريحة لحم بقري، جبنة شيدر، خس، طماطم، صوص خاص',
                              style: TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Color(0xFF99A1AF),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '150',
                                style: TextStyle().textColorBold(
                                  fontSize: 18.sp,
                                  color: Color(0xFF7F22FE),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'د.ل',
                                style: TextStyle().textColorNormal(
                                  fontSize: 12.sp,
                                  color: Color(0xFF99A1AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 24.w),
          child: Text(
            'تصفح المنيو',
            style: TextStyle().textColorBold(
              fontSize: 18.sp,
              color: Color(0xFF101828),
            ),
          ),
        ),

        SizedBox(height: 16.h),

        SizedBox(
          height: 140.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 24.w),
              _buildMenuCategoryCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200",
                title: 'برجر',
                count: '12 وجبة',
              ),
              SizedBox(width: 16.w),
              _buildMenuCategoryCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=200",
                title: 'ساندوتش',
                count: '8 أنواع',
              ),
              SizedBox(width: 16.w),
              _buildMenuCategoryCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
                title: 'وجبات',
                count: '5 عروض',
              ),
              SizedBox(width: 16.w),
              _buildMenuCategoryCard(
                imageUrl:
                    "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=200",
                title: 'مشروبات',
                count: '14 نوع',
              ),
              SizedBox(width: 24.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCategoryCard({
    required String imageUrl,
    required String title,
    required String count,
  }) {
    return Container(
      width: 120.w,
      height: 140.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 120.w,
              height: 140.h,
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Content
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  count,
                  style: TextStyle().textColorNormal(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            spacing: 8.w,
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              Text(
                'جميع الأصناف',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Items List
          ...List.generate(3, (index) => _buildItemCard(context)),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MealDetailsDialog(),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 88.w,
              height: 76.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200",
                  width: 88.w,
                  height: 76.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وجبة فواكه البحر',
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Color(0xFF0A191E),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'وجبات صحية',
                    style: TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Color(0xFF0A191E),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '15 د.ل',
                    style: TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Color(0xFF0A191E),
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Selector
            _buildQuantitySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      width: 70.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: Color(0xFF121223),
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100.r),
            onTap: () {},
            child: SvgIcon(
              iconName: 'assets/svg/client/restaurant_details/minus_icon.svg',
              width: 14,
              height: 14,
              color: Colors.white,
            ),
          ),
          Text(
            '0',
            style: TextStyle().textColorBold(
              fontSize: 10.sp,
              color: Colors.white,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(100.r),
            onTap: () {},
            child: SvgIcon(
              iconName: 'assets/svg/client/restaurant_details/plus_icon.svg',
              width: 14,
              height: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
