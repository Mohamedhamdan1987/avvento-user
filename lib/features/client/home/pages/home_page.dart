import 'dart:ui';

import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_text_field.dart';
import 'package:avvento/features/client/address/controllers/address_controller.dart';
import '../../restaurants/pages/restaurant_details_screen.dart';
import '../bindings/home_binding.dart';
import '../controllers/home_controller.dart';
import '../widgets/category_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/restaurant_circle_item.dart';
import '../widgets/discount_card.dart';
import '../../favorites/pages/favorites_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure HomeController is initialized
    if (!Get.isRegistered<HomeController>()) {
      // Initialize the controller if not already registered
      HomeBinding().dependencies();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        // Ensure controller is registered before accessing it
        if (!Get.isRegistered<HomeController>()) {
          return const Center(child: CircularProgressIndicator());
        }
        // Get controller inside Obx to ensure it's available
        final controller = Get.find<HomeController>();
        return controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _HomePageContent(controller: controller);
      }),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  final HomeController controller;

  const _HomePageContent({required this.controller});

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  late ScrollController _scrollController;
  late PageController _promoPageController;
  double _scrollOffset = 0.0;
  static const double _maxScrollOffset = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _promoPageController = PageController(initialPage: widget.controller.currentPromoPage);
    
    // Update FCM token on server
    NotificationService.instance.updateTokenOnServer();
    
    // Connect to socket for real-time order updates
    try {
      final socketService = Get.find<SocketService>();
      socketService.connectToNotifications();
    } catch (e) {
      // SocketService not initialized yet
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _promoPageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset.clamp(0.0, _maxScrollOffset);
    });
  }

  /// Show test notification dialog (DEBUG ONLY)
  void _showTestNotificationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '🧪 اختبار إشعارات الطلبات',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              
              // Test single status buttons
              Text(
                'اختبار حالة معينة:',
                style: TextStyle().textColorMedium(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: 12.h),
              
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: OrderStatus.values.map((status) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      NotificationService.instance.showTestOrderNotification(status);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == OrderStatus.cancelled 
                          ? Colors.red 
                          : status == OrderStatus.delivered 
                              ? Colors.green 
                              : AppColors.purple,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle().textColorMedium(
                        fontSize: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 24.h),
              
              // Test all statuses button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  NotificationService.instance.showTestAllStatusesNotification();
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  'اختبار جميع الحالات (تلقائي)',
                  style: TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              Text(
                '⚠️ هذا الزر للاختبار فقط - احذفه قبل النشر',
                style: TextStyle().textColorMedium(
                  fontSize: 10.sp,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Test notification button (DEBUG ONLY - Remove in production)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTestNotificationDialog(context),
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        label: Text(
          'اختبار الإشعارات',
          style: TextStyle().textColorBold(fontSize: 12.sp, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Column(
        children: [
          // Header with gradient background
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Content sections
                  _buildContent(),
                  // Bottom spacing for nav bar
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildHeader() {
    final addressController = Get.find<AddressController>();
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
                // top: 56.h,
                left: 20.w,
                right: 20.w,
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
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconButtonApp(
                              onTap: () {
                                Get.toNamed(AppRoutes.notifications);
                              },
                              childWidget: SvgPicture.asset(
                                'assets/svg/client/home/notification.svg',
                                width: 20.w,
                                height: 20.h,
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
                              width: 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: AppColors.notificationRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.purple,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Location
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.addressList),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 0.h,
                          ),
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.28),
                            borderRadius: BorderRadius.circular(20.r),
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
                              SizedBox(width: 4.w),
                              Obx(() => Text(
                                    addressController.activeAddress.value?.label ?? 'اختر عنوان',
                                    style: const TextStyle().textColorLight(
                                      fontSize: 12,
                                      color: AppColors.white.withOpacity(0.9),
                                    ),
                                  )),
                              SizedBox(width: 4.w),
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
                      ),
                    ],
                  ),
                  // SizedBox(height: 16.h),
                  Spacer(),
                  // App title
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أفينتو',
                      style: const TextStyle().textColorBlack(
                        fontSize: 20,
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
                      ],
                    ),
                    child: CustomTextField(
                      hint: 'ابحث عن وجبتك المفضلة...',
                      fillColor: Theme.of(context).cardColor,
                      borderRadius: 16,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      prefixIconWidget: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SvgPicture.asset(
                          'assets/svg/client/home/search.svg',
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

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
        top: 16.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Grid
          SizedBox(
            height: 128.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryCard(
                  iconPath: 'assets/svg/client/home/store.svg',
                  title: 'المتاجر',
                  onTap: () {},
                ),
                SizedBox(width: 14.w),
                CategoryCard(
                  iconPath: 'assets/svg/client/home/pharmacy.svg',
                  title: 'صيدليات',
                  onTap: () {},
                ),
                SizedBox(width: 14.w),
                CategoryCard(
                  iconPath: 'assets/svg/client/home/grocery.svg',
                  title: 'الغدائية',
                  onTap: () {},
                ),
                SizedBox(width: 14.w),
                CategoryCard(
                  iconPath: 'assets/svg/client/home/restaurant.svg',
                  title: 'المطاعم',
                  onTap: () {
                    Get.toNamed(AppRoutes.restaurants);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Promo Carousel
          Obx(() {
            if (widget.controller.featuredRestaurants.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                SizedBox(
                  height: 216.h,
                  child: PageView.builder(
                    controller: _promoPageController,
                    onPageChanged: (index) {
                      widget.controller.setCurrentPromoPage(index);
                    },
                    itemBuilder: (context, index) {
                      final restaurant = widget.controller.featuredRestaurants[index];
                      return PromoCard(
                        imageUrl: restaurant.backgroundImage ?? 'assets/home_cover.jpg',
                        restaurantName: restaurant.name,
                        rating: 4.5, // Hardcoded for now as API might not provide it
                        distance: '${(index + 1) * 0.5}k', // Dummy distance
                        deliveryFee: '0',
                        hasFreeDelivery: true,
                        isFavorite: restaurant.isFavorite,
                        onTap: () {
                          Get.to(() => RestaurantDetailsScreen(restaurantId: restaurant.id));

                        },
                        onFavoriteTap: () => widget.controller.toggleFavorite(restaurant),
                      );
                    },
                    itemCount: widget.controller.featuredRestaurants.length,
                  ),
                ),
                SizedBox(height: 16.h),
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.controller.featuredRestaurants.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: index == widget.controller.currentPromoPage ? 20.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: index == widget.controller.currentPromoPage
                            ? AppColors.purple
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    );
                  }),
                ),
              ],
            );
          }),
          SizedBox(height: 24.h),
          // Favorite Restaurants Section
          _buildSectionHeader(
            title: 'المطاعم المفضلة',
            onViewAllTap: () => Get.to(() => const FavoritesPage()),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (widget.controller.favoriteRestaurants.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد مطاعم مفضلة حالياً',
                  style: const TextStyle().textColorLight(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 110.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.controller.favoriteRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = widget.controller.favoriteRestaurants[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: RestaurantCircleItem(
                      imageUrl: restaurant.logo ?? 'assets/home_cover.jpg',
                      restaurantName: restaurant.name,
                      onTap: () {
                        Get.to(() => RestaurantDetailsScreen(restaurantId: restaurant.id));
                      },
                    ),
                  );
                },
              ),
            );
          }),
          SizedBox(height: 24.h),
          // Weekly Discounts Section
          _buildSectionHeader(
            title: 'خصومات الاسبوع 🔥',
            onViewAllTap: () {},
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 176.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                DiscountCard(
                  type: DiscountCardType.purple,
                  title: 'عرض',
                  subtitle: 'اليوم',
                  onTap: () {},
                ),
                SizedBox(width: 16.w),
                DiscountCard(
                  type: DiscountCardType.black,
                  imageUrl: 'assets/home_cover.jpg',
                  title: 'خصومات',
                  onTap: () {},
                ),
                SizedBox(width: 16.w),
                DiscountCard(
                  type: DiscountCardType.white,
                  imageUrl: 'assets/home_cover.jpg',
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
            style: const TextStyle().textColorBold(
              fontSize: 12,
              color: AppColors.purple,
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle().textColorBold(
            fontSize: 15,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ],
    );
  }
}
