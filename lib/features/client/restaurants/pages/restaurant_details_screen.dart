import 'dart:math';
import 'dart:ui';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/utils/show_snackbar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/features/client/restaurants/models/menu_item_model.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:avvento/features/client/restaurants/pages/category_menu_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/svg_icon.dart';
import '../controllers/restaurant_details_controller.dart';
import '../../../../core/utils/location_utils.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/pages/restaurant_cart_details_page.dart';
import '../controllers/restaurants_controller.dart';
import 'meal_details_dialog.dart';
import 'restaurant_search_page.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final String restaurantId;

  RestaurantDetailsScreen({super.key, required this.restaurantId}) {
    if (!Get.isRegistered<RestaurantsController>()) {
      Get.put(RestaurantsController());
    }
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    } else {
      // Use microtask to avoid "setState() or markNeedsBuild() called during build" error
      Future.microtask(() => Get.find<CartController>().fetchAllCarts());
    }
    Get.delete<RestaurantDetailsController>(); // Ensure fresh controller
    Get.put(RestaurantDetailsController(restaurantId: restaurantId));
  }

  RestaurantDetailsController get controller => Get.find<RestaurantDetailsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        final cartController = Get.find<CartController>();
        final cart = cartController.carts.firstWhereOrNull(
          (c) => c.restaurant.restaurantId == restaurantId,
        );

        if (cart == null || cart.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildViewCartButton(context, cart);
      }),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoadingRestaurantDetails && controller.restaurant == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError && controller.restaurant == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.w, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      controller.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: controller.getRestaurantDetails,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.restaurant == null) {
            return const Center(child: Text('المطعم غير موجود'));
          }


          return CustomScrollView(
            slivers: [
              // Shrinking Header
              SliverPersistentHeader(
                pinned: true,
                delegate: RestaurantHeaderDelegate(
                  restaurant: controller.restaurant!,
                  onBack: () => Navigator.pop(context),
                  onSearch: () {
                    Get.to(() => RestaurantSearchPage(
                          restaurant: controller.restaurant!,
                          categories: controller.categories,
                          allItems: controller.allItems,
                        ));
                  },
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),

                    // Restaurant Stats Row
                    _buildOpenStats(context),

                    SizedBox(height: 14.h),
                    _buildStatsRow(context),

                    SizedBox(height: 14.h),

                    // Browse Menu Section
                    _buildBrowseMenuSection(context),

                    SizedBox(height: 32.h),

                    // All Items Section
                    _buildAllItemsSection(context),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Header section refactored into RestaurantHeaderDelegate

  // Profile picture refactored into RestaurantHeaderDelegate

  Widget _buildOpenStats(BuildContext context) {
    return InkWell(
      onTap: () => _showOpeningHoursSheet(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final isOpen = controller.schedule?.isOpen ?? controller.restaurant?.isOpen ?? false;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isOpen ? Colors.green : Colors.red).withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isOpen ? 'مفتوح الآن' : 'مغلق حالياً',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 4.h),
                Obx(() {
                  final status = controller.schedule?.currentDayStatus;
                  if (status == null) return const SizedBox.shrink();
                  
                  final nextTime = status.isCurrentlyOpen ? status.closeTime : status.openTime;
                  final text = status.isCurrentlyOpen ? 'يغلق الساعة $nextTime' : 'يفتح الساعة $nextTime';
                  
                  return Text(
                    text,
                    style: TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  );
                }),
              ],
            ),
            Row(
              children: [
                Text(
                  'مواعيد العمل',
                  style: TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: AppColors.purple,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20.w,
                  color: AppColors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOpeningHoursSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsetsDirectional.only(top: 16.w, start: 16.w, bottom: 24.w, end: 8.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              // Container(
              //   width: 40.w,
              //   height: 4.h,
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).dividerColor,
              //     borderRadius: BorderRadius.circular(2.r),
              //   ),
              // ),
              // SizedBox(height: 24.h),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgIcon(
                      iconName: 'assets/svg/client/restaurant_details/clock.svg',
                      width: 24.w,
                      height: 24.h,
                      color: AppColors.purple,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواعيد العمل',
                          style: TextStyle().textColorBold(
                            fontSize: 18.sp,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        Text(
                          controller.restaurant?.name ?? '',
                          style: TextStyle().textColorMedium(
                            fontSize: 14.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Days List
              Obx(() {
                if (controller.isLoadingSchedule) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final schedule = controller.schedule;
                if (schedule == null) {
                  return const Center(child: Text('لا توجد بيانات مواعيد'));
                }

                final daysArabic = {
                  'sunday': 'الأحد',
                  'monday': 'الاثنين',
                  'tuesday': 'الثلاثاء',
                  'wednesday': 'الأربعاء',
                  'thursday': 'الخميس',
                  'friday': 'الجمعة',
                  'saturday': 'السبت',
                };

                return Column(
                  children: schedule.weeklySchedule.map((s) {
                    final isCurrent = s.day.toLowerCase() == schedule.currentDayStatus.day.toLowerCase();
                    final hoursText = s.isClosed ? 'مغلق' : '${s.openTime} - ${s.closeTime}';
                    return _buildDayRow(context, daysArabic[s.day.toLowerCase()] ?? s.day, hoursText, isCurrent: isCurrent);
                  }).toList(),
                );
              }),
              
              SizedBox(height: 32.h),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String day, String hours, {bool isCurrent = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.purple.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isCurrent ? Border.all(color: AppColors.purple.withOpacity(0.2)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle().textColorMedium(
              fontSize: 14.sp,
              color: isCurrent ? AppColors.purple : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          Text(
            hours,
            style: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: isCurrent ? AppColors.purple : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    String distanceText = '--';
    String priceText = '--';
    final restaurantsController = Get.find<RestaurantsController>();
    if (restaurantsController.userLat != null && restaurantsController.userLong != null) {
      final distance = LocationUtils.calculateDistance(
        userLat: restaurantsController.userLat!,
        userLong: restaurantsController.userLong!,
        restaurantLat: controller.restaurant!.lat,
        restaurantLong: controller.restaurant!.long,
      );
      distanceText = LocationUtils.formatDistance(distance);
      final price = LocationUtils.calculateDeliveryPrice(distanceInKm: distance, );
      priceText = LocationUtils.formatPrice(price);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
      decoration: ShapeDecoration(
        color: const Color(0x11D9D9D9),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x33E3E3E3),
          ),
          borderRadius: BorderRadius.circular(21),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/clock.svg',
            value: '${controller.restaurant!.averagePreparationTimeMinutes} دقيقة',
            label: 'التحضير',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/location.svg',
            value: distanceText,
            label: 'المسافة',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/bike.svg',
            value: priceText,
            label: 'التوصيل',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/inactive_star_icon.svg',
            value: controller.restaurant!.averageRatingDisplay,
            label: 'التقييم',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
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
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysOffersSection(BuildContext context) {
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
                  color: Theme.of(context).textTheme.titleLarge?.color,
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
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
                          color: Theme.of(context).colorScheme.surface,
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
                        color: Color(0xFF101828), // This button color might need check, maybe dark compliant or kept as brand
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
                          color: Theme.of(context).textTheme.titleMedium?.color,
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
                                color: Theme.of(context).textTheme.bodySmall?.color,
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
                                  color: Theme.of(context).textTheme.bodySmall?.color,
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

  Widget _buildBrowseMenuSection(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 24.w),
          child: Text(
            'تصفح المنيو',
            style: const TextStyle().textColorBold(
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        SizedBox(
          height: 140.h,
          child: Obx(() {
            if (controller.isLoadingCategories && controller.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.categories.isEmpty) {
              return const Center(child: Text('لا توجد تصنيفات'));
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return GestureDetector(
                   behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.to(() => CategoryMenuPage(
                          restaurant: controller.restaurant!,
                          category: category,
                        ));
                  },
                  child: _buildMenuCategoryCard(
                    imageUrl: category.image ?? "",
                    title: category.name,
                    count: "",
                    isSelected: false, // No selection state on the main screen anymore
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMenuCategoryCard({
    required String imageUrl,
    required String title,
    required String count,
    bool isSelected = false,
  }) {
    return Container(
      width: 120.w,
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: isSelected ? Border.all(color: Color(0xFF7F22FE), width: 2.w) : null,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 120.w,
                    height: 140.h,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[300]),
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
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                if (count.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    count,
                    style: const TextStyle().textColorNormal(
                      fontSize: 10.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
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
                style: const TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Items List
          Obx(() {
            if (controller.isLoadingItems && controller.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.items.isEmpty) {
              return const Center(child: Text('لا توجد أصناف'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < controller.items.length; i++) ...[
                  if (i == 0 ||
                      controller.items[i].categoryId !=
                          controller.items[i - 1].categoryId)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 16.h, bottom: 8.h),
                      child: Text(
                        controller.items[i].categoryName,
                        style: const TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Colors.grey, // Changed to grey as requested
                        ),
                      ),
                    ),
                  _buildItemCard(context, controller.items[i]),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItem item) {
    final cartController = Get.find<CartController>();
    final quantity = cartController.getItemQuantityInCart(restaurantId, item.id);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Item Image with Add Button
            GestureDetector(
              onTap: () {
                _showMealDetails(context, item);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 96.w,
                  height: 96.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: (item.image?.isNotEmpty ?? false)
                      ? CachedNetworkImage(
                    imageUrl: item.image!,
                    width: 96.w,
                    height: 96.h,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.fastfood, size: 40.w, color: Colors.grey),
                ),
              ),
            ),


            SizedBox(width: 12.w),

            // Item Details
            Expanded(
              child: GestureDetector(
                onTap: () => _showMealDetails(context, item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle().textColorBold(
                              fontSize: 16.sp,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        quantity > 0
                            ? Container(
                          height: 28.h,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101828),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _updateQuantity(context, item, quantity - 1),
                                child: Icon(Icons.remove, color: Colors.white, size: 16.w),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '$quantity',
                                style: TextStyle().textColorBold(fontSize: 14.sp, color: Colors.white),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () => _updateQuantity(context, item, quantity + 1),
                                child: Icon(Icons.add, color: Colors.white, size: 16.w),
                              ),
                            ],
                          ),
                        )
                            : CustomIconButtonApp(
                          width: 32.w,
                          height: 32.h,
                          radius: 100.r,
                          color: const Color(0xFF101828),
                          onTap: () {
                            if (item.variations.isEmpty && item.addOns.isEmpty) {
                              controller.addToCart(
                                itemId: item.id,
                                quantity: 1,
                                selectedVariations: [],
                                selectedAddOns: [],
                              );
                            } else {
                              _showMealDetails(context, item);
                            }
                          },
                          childWidget: SvgIcon(
                            iconName: 'assets/svg/plus-solid.svg',
                            width: 16.w,
                            height: 16.h,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.description,
                      style: TextStyle().textColorNormal(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.price.toString(),
                          style: TextStyle().textColorBold(
                            fontSize: 18.sp,
                            color: AppColors.purple,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'د.ل',
                          style: TextStyle().textColorNormal(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(MenuItem item) {
    return Obx(() {
      final isFav = controller.isItemFavorite(item.id);
      return GestureDetector(
        onTap: () => controller.toggleFavorite(item.id),
        child: SvgIcon(
          iconName: isFav
              ? 'assets/svg/client/restaurant_details/active_fav_icon.svg'
              : 'assets/svg/client/restaurant_details/fav_icon.svg',
          width: 20.w,
          height: 20.h,
          color: isFav ? Colors.red : null,
        ),
      );
    });
  }

  void _showMealDetails(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MealDetailsDialog(
        menuItem: item,
      ),
    );
  }

  Widget _buildViewCartButton(BuildContext context, RestaurantCartResponse cart) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: CustomButtonApp(
        onTap: () {
          Get.to(() => RestaurantCartDetailsPage(
            cart: cart,
          ));
        },
        height: 56.h,
        borderRadius: 16.r,
        color: AppColors.purple,
        isFill: true,
        childWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${cart.items.length}',
                    style: TextStyle().textColorBold(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'عرض السلة',
                  style: TextStyle().textColorBold(fontSize: 16.sp, color: Colors.white),
                ),
              ],
            ),
            Text(
              '${cart.totalPrice} د.ل',
              style: TextStyle().textColorBold(fontSize: 16.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(BuildContext context, MenuItem item, int newQuantity) {
    final cartController = Get.find<CartController>();
    final itemIndex = cartController.getItemIndexInCart(restaurantId, item.id);

    if (newQuantity == 0) {
      if (itemIndex != -1) {
        cartController.removeItem(restaurantId, itemIndex);
      }
    } else {
      if (itemIndex != -1) {
        cartController.updateCartItemQuantity(restaurantId, itemIndex, newQuantity);
      } else {
        controller.addToCart(
          itemId: item.id,
          quantity: newQuantity,
          selectedVariations: [],
          selectedAddOns: [],
        );
      }
    }
  }
}

class RestaurantHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Restaurant restaurant;
  final VoidCallback onBack;
  final VoidCallback onSearch;

  RestaurantHeaderDelegate({
    required this.restaurant,
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = shrinkOffset / maxExtent;
    // Calculate values based on progress
    final double avatarSize = 100.w * (1 - progress).clamp(0.6, 1.0);
    final double avatarTop = 150.h - (shrinkOffset * 0.7);
    final double titleOpacity = (progress * 2).clamp(0, 1);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with Blur
        ClipRRect(
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: restaurant.backgroundImage ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: progress * 10,
                  sigmaY: progress * 10,
                ),
                child: Container(
                  color: Colors.black.withOpacity(progress * 0.4),
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButtonApp(
                onTap: onBack,
                color: Colors.white.withOpacity(0.2),
                childWidget: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
              // Fade in title when scrolled
              Opacity(
                opacity: titleOpacity,
                child: Text(
                  restaurant.name,
                  style: TextStyle().textColorBold(fontSize: 18.sp, color: Colors.white),
                ),
              ),
              CustomIconButtonApp(
                onTap: onSearch,
                color: Colors.white.withOpacity(0.2),
                childWidget: SvgIcon(
                  iconName: 'assets/svg/client/search.svg',
                  color: Colors.white,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ],
          ),
        ),

        // Profile Picture (Avatar)
        Positioned(
          top: avatarTop.clamp(MediaQuery.of(context).padding.top + 10.h, 150.h),
          right: 24.w,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: restaurant.logo ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
              ),
            ),
          ),
        ),
        
        // Name & Info (Bottom of header)
        if (progress < 0.8)
        Positioned(
          bottom: 20.h,
          left: 24.w,
          right: 130.w, // Leave room for avatar
          child: Opacity(
            opacity: (1 - progress * 2).clamp(0, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  style: TextStyle().textColorBold(
                    fontSize: 24.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'الحد الأدنى للطلب: 25 د.ل',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 250.h;

  @override
  double get minExtent => 100.h + Get.mediaQuery.padding.top;

  @override
  bool shouldRebuild(covariant RestaurantHeaderDelegate oldDelegate) => true;
}

