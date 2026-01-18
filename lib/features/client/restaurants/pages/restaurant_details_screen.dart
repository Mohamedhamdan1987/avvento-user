import 'dart:math';
import 'dart:ui';
import 'package:avvento/core/theme/app_text_styles.dart';
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
      Get.find<CartController>().fetchAllCarts(); // Force refresh to get latest state
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
          if (controller.isLoadingRestaurantDetails || controller.restaurant == null ) {
            return const Center(child: CircularProgressIndicator());
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
      final price = LocationUtils.calculateDeliveryPrice(distanceInKm: distance);
      priceText = LocationUtils.formatPrice(price);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 34.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/clock.svg',
            value: '25 دقيقة', // This could be dynamic if restaurant has preparation time
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
            value: '4.8',
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
          color: Theme.of(context).iconTheme.color,
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
              children: controller.items.map((item) => _buildItemCard(context, item)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MealDetailsDialog(menuItem: item),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: item.image != null && item.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.image!,
                        width: 88.w,
                        height: 76.h,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey[300]),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(children: [
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: Theme.of(context).textTheme.titleMedium?.color,
                              ),
                            ),
                            // const Spacer(),
                            // GestureDetector(
                            //   onTap: () => controller.toggleFavorite(item.id),
                            //   child: Padding(
                            //     padding: EdgeInsets.symmetric(horizontal: 4.w),
                            //     child: Icon(
                            //       item.isFav ? Icons.favorite : Icons.favorite_border,
                            //       size: 20.w,
                            //       color: item.isFav ? Colors.red : Colors.grey[400],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle().textColorMedium(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),

                      ],
                    ),
                  ),

                  // Quantity Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // favorite
                      GestureDetector(
                        onTap: () => controller.toggleFavorite(item.id),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            item.isFav ? Icons.favorite : Icons.favorite_border,
                            size: 20.w,
                            color: item.isFav ? AppColors.primary : Colors.grey[400],
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${item.price} د.ل',
                        style: const TextStyle().textColorMedium(
                          fontSize: 12.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      // _buildQuantitySelector(),
                    ],
                  ),
                ],),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container();
  }

  Widget _buildViewCartButton(BuildContext context, RestaurantCartResponse cart) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Get.to(() => RestaurantCartDetailsPage(cart: cart));
            // Refresh if needed when coming back
            Get.find<CartController>().refreshCarts();
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${cart.items.length}',
                    style: const TextStyle().textColorBold(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'عرض السلة',
                  style: const TextStyle().textColorBold(fontSize: 16.sp, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  '${cart.totalPrice.toStringAsFixed(0)} د.ل',
                  style: const TextStyle().textColorBold(fontSize: 16.sp, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  double get minExtent => 85.h + Get.mediaQuery.padding.top;

  @override
  double get maxExtent => 180.h + Get.mediaQuery.padding.top;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtent - minExtent);
    final double clampedProgress = progress.clamp(0.0, 1.0);

    // Reverse progress for elements that should disappear (1.0 at expanded, 0.0 at collapsed)
    final double reverseProgress = 1.0 - clampedProgress;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Background Image with Gradient
        _buildBackground(clampedProgress),

        // Bottom Content (Logo, Name, Description) - Animates on scroll
        _buildBottomContent(clampedProgress, reverseProgress),

        // Top Navigation Bar
        _buildTopBar(context, reverseProgress, clampedProgress),
      ],
    );
  }

  Widget _buildBackground(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(lerpDouble(40.r, 8.r, progress)!),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          restaurant.backgroundImage != null
              ? CachedNetworkImage(
                  imageUrl: restaurant.backgroundImage!,
                  fit: BoxFit.cover,
                )
              : Container(color: Colors.grey[300]),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double reverseProgress, double progress) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: minExtent,
        padding: EdgeInsets.only(top: Get.mediaQuery.padding.top, left: 16.w, right: 16.w),
        child: Row(
          children: [
            CustomIconButtonApp(
              width: 38.w,
              height: 38.h,
              radius: 100.r,
              color: Color(0xB37F22FE).withOpacity(lerpDouble(0.7, 0.9, progress)!),
              onTap: onBack,
              childWidget: SvgIcon(
                iconName: 'assets/svg/arrow-right.svg',
                width: 18.w,
                height: 18.h,
                color: Colors.white,
              ),
            ),

            // Collapsed Name (Fades in)
            Expanded(
              child: Opacity(
                opacity: progress > 0.6 ? (progress - 0.6) / 0.4 : 0.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    restaurant.name,
                    style: const TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            // Navigation Actions (Search & Share) - Fades out
            Opacity(
              opacity: reverseProgress > 0.3 ? (reverseProgress - 0.3) / 0.7 : 0.0,
              child: Row(
                children: [
                  CustomIconButtonApp(
                    width: 38.w,
                    height: 38.h,
                    radius: 100.r,
                    color: Color(0x997F22FE),
                    onTap: onSearch,
                    childWidget: SvgIcon(
                      iconName: 'assets/svg/search-icon.svg',
                      width: 18.w,
                      height: 18.h,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CustomIconButtonApp(
                    width: 38.w,
                    height: 38.h,
                    radius: 100.r,
                    color: Color(0x997F22FE),
                    onTap: () {},
                    childWidget: SvgIcon(
                      iconName: 'assets/svg/share_icon.svg',
                      width: 18.w,
                      height: 18.h,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent(double progress, double reverseProgress) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Restaurant Name and Description (Fades out)
        Positioned(
          bottom: 12.h + (35.h * progress),
          right: 24.w,
          child: Opacity(
            opacity: reverseProgress.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  restaurant.description,
                  style: const TextStyle().textColorMedium(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Profile Picture Animation
        PositionedDirectional(
          bottom: lerpDouble(-45.h, 12.h, progress),
          end: lerpDouble(43.w, 12.w, progress),
          child: Transform.scale(
            scale: lerpDouble(1.0, 0.45, progress)!,
            alignment: AlignmentDirectional.bottomEnd,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: 90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2.w),
                ),
                child: ClipOval(
                  child: restaurant.logo != null
                      ? CachedNetworkImage(
                          imageUrl: restaurant.logo!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.restaurant, size: 35.r),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant RestaurantHeaderDelegate oldDelegate) {
    return oldDelegate.restaurant != restaurant;
  }
}
