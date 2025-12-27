import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/screen_util_extensions.dart';
import '../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../shared/widgets/navigation/client_bottom_nav_bar.dart';
import '../widgets/category_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/restaurant_circle_item.dart';
import '../widgets/discount_card.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final PageController _promoPageController = PageController();
  int _currentPromoPage = 0;
  ClientNavItem _currentNavItem = ClientNavItem.home;

  @override
  void dispose() {
    _promoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header with gradient background
                _buildHeader(),
                // Content sections
                _buildContent(),
                // Bottom spacing for nav bar
                SizedBox(height: 100.h),
              ],
            ),
          ),
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClientBottomNavBar(
              currentIndex: _currentNavItem,
              onTap: (item) {
                setState(() {
                  _currentNavItem = item;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 277.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(19.r),
          bottomRight: Radius.circular(19.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(19.r),
              bottomRight: Radius.circular(19.r),
            ),
            child: Image.asset(
              'assets/home_cover.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.purple,
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(19.r),
                bottomRight: Radius.circular(19.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  const Color(0xFF9C19FA).withOpacity(0.8),
                  const Color(0xFF9B16FA).withOpacity(0.964),
                ],
                stops: const [0.0, 0.63462, 0.94231],
              ),
            ),
          ),
          // Header content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: 56.h,
                left: 19.992.w,
                right: 19.992.w,
              ),
              child: Column(
                children: [
                  // Top bar with notification and location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Notification button
                      Stack(
                        children: [
                          Container(
                            width: 39.996.w,
                            height: 39.996.h,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/client/home/notification.svg',
                                width: 19.992.w,
                                height: 19.992.h,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          // Red dot
                          Positioned(
                            top: 28.h,
                            right: 32.w,
                            child: Container(
                              width: 9.99.w,
                              height: 9.99.h,
                              decoration: BoxDecoration(
                                color: AppColors.notificationRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.purple,
                                  width: 1.522,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Location
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 0.h,
                        ),
                        height: 23.988.h,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(25539800.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/client/home/location_pin.svg',
                              width: 12.w,
                              height: 12.h,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 3.996.w),
                            Text(
                              'طرابلس، حي الأندلس',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(width: 3.996.w),
                            SvgPicture.asset(
                              'assets/svg/client/home/chevron_down.svg',
                              width: 12.w,
                              height: 12.h,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.996.h),
                  // App title
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أفينتو',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Search bar
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D179A).withOpacity(0.1),
                          offset: const Offset(0, 10),
                          blurRadius: 15,
                          spreadRadius: -3,
                        ),
                        BoxShadow(
                          color: const Color(0xFF4D179A).withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        CustomTextField(
                          hint: 'ابحث عن وجبتك المفضلة...',
                          fillColor: AppColors.white,
                          borderRadius: 16,
                          contentPadding: EdgeInsets.only(
                            left: 16.w,
                            right: 48.w,
                            top: 12.h,
                            bottom: 12.h,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(
                              'assets/svg/client/home/search.svg',
                              width: 19.992.w,
                              height: 19.992.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: 15.98.h,
        left: 19.992.w,
        right: 19.992.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Grid
          SizedBox(
            height: 127.992.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryCard(
                  iconPath: 'assets/svg/client/home/store.svg',
                  title: 'المتاجر',
                  onTap: () {},
                ),
                SizedBox(width: 14.19.w),
                CategoryCard(
                  iconPath: 'assets/svg/client/home/pharmacy.svg',
                  title: 'صيدليات',
                  onTap: () {},
                ),
                SizedBox(width: 14.19.w),
                CategoryCard(
                  iconPath: 'assets/svg/client/home/grocery.svg',
                  title: 'الغدائية',
                  onTap: () {},
                ),
                SizedBox(width: 14.19.w),
                CategoryCard(
                  iconPath: 'assets/svg/client/home/restaurant.svg',
                  title: 'المطاعم',
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Promo Carousel
          Column(
            children: [
              SizedBox(
                height: 216.h,
                child: PageView.builder(
                  controller: _promoPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPromoPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return PromoCard(
                      imageUrl: 'https://via.placeholder.com/345x216',
                      restaurantName: 'مطعم الكوخ',
                      rating: 4.5,
                      distance: '1.2k',
                      deliveryFee: '0',
                      hasFreeDelivery: true,
                      isFavorite: false,
                      onTap: () {},
                      onFavoriteTap: () {},
                    );
                  },
                  itemCount: 4,
                ),
              ),
              SizedBox(height: 15.996.h),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.997.w),
                    width: index == _currentPromoPage ? 19.992.w : 5.994.w,
                    height: 5.994.h,
                    decoration: BoxDecoration(
                      color: index == _currentPromoPage
                          ? AppColors.purple
                          : AppColors.borderGray,
                      borderRadius: BorderRadius.circular(25539800.r),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Favorite Restaurants Section
          _buildSectionHeader(
            title: 'المطاعم المفضلة',
            onViewAllTap: () {},
          ),
          SizedBox(height: 15.98.h),
          SizedBox(
            height: 110.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                RestaurantCircleItem(
                  imageUrl: 'https://via.placeholder.com/70',
                  restaurantName: 'شاورما الخليل',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                RestaurantCircleItem(
                  imageUrl: 'https://via.placeholder.com/70',
                  restaurantName: 'مطعم الطازج',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                RestaurantCircleItem(
                  imageUrl: 'https://via.placeholder.com/70',
                  restaurantName: 'بيتزا كينغ',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                RestaurantCircleItem(
                  imageUrl: 'https://via.placeholder.com/70',
                  restaurantName: 'الدجاج المشوي',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                RestaurantCircleItem(
                  imageUrl: 'https://via.placeholder.com/70',
                  restaurantName: 'فطائر النخيل',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                RestaurantCircleItem(
                  imageUrl: 'https://via.placeholder.com/70',
                  restaurantName: 'مطعم النجم الذهبي',
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Weekly Discounts Section
          _buildSectionHeader(
            title: 'خصومات الاسبوع 🔥',
            onViewAllTap: () {},
          ),
          SizedBox(height: 15.98.h),
          SizedBox(
            height: 175.991.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                DiscountCard(
                  type: DiscountCardType.purple,
                  title: 'عرض',
                  subtitle: 'اليوم',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                DiscountCard(
                  type: DiscountCardType.black,
                  imageUrl: 'https://via.placeholder.com/145x176',
                  title: 'خصومات',
                  onTap: () {},
                ),
                SizedBox(width: 15.996.w),
                DiscountCard(
                  type: DiscountCardType.white,
                  imageUrl: 'https://via.placeholder.com/145x176',
                  title: 'اللمة',
                  subtitle: 'أوفر',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAllTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onViewAllTap,
          child: Text(
            'عرض الكل',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
        ),
        Text(
          title,
          style: AppTextStyles.h5.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
