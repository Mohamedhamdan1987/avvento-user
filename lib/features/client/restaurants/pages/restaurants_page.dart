import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/restaurants_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../../../core/utils/location_utils.dart';
import 'story_view_page.dart';
import 'all_stories_page.dart';
import 'restaurant_details_screen.dart';

class RestaurantsPage extends GetView<RestaurantsController> {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'المطاعم',
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == controller.searchQuery) return;
                  controller.searchRestaurants(value);
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'ابحث عن مطعم...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: CustomIconButtonApp(
                  childWidget: SvgIcon(
                    iconName: "assets/svg/client/search.svg",
                  ),
                  onTap: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    width: 0.76,
                    color: Color(0xFFE4E4E4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    width: 0.76,
                    color: Color(0xFFE4E4E4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    width: 0.76,
                    color: Color(0xFFE4E4E4),
                  ),
                ),
              ),
            ),
          ),

          // Restaurants List
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading && controller.restaurants.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (controller.hasError && controller.restaurants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchRestaurants,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              // Empty state
              if (controller.restaurants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مطاعم',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              // Restaurants list
              return RefreshIndicator(
                onRefresh: controller.refreshRestaurants,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Stories Section
                      if (controller.stories.isNotEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24.w,
                          top: 16.h,
                          bottom: 8.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgIcon(
                                  iconName: "assets/svg/client/fire.svg",
                                  color: const Color(0xFFFFA800),
                                  width: 24.w,
                                  height: 24.h,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'ستوري المطاعم',
                                  style: const TextStyle(
                                    color: Color(0xFF101727),
                                    fontSize: 18,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.w700,
                                    height: 1.56,
                                  ).textColorBold(),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => AllStoriesPage(
                                    stories: controller.stories,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 24.w),
                                child: Text(
                                  'مشاهدة الكل',
                                  style:
                                      const TextStyle(
                                        color: Color(0xFF7F22FE),
                                        fontSize: 12,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontWeight: FontWeight.w700,
                                        height: 1.33,
                                      ).textColorBold(
                                        color: const Color(0xFF7F22FE),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stories List (Horizontal)
                      if (controller.stories.isNotEmpty)
                        SizedBox(
                          height: 100.h,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            scrollDirection: Axis.horizontal,
                            // Limit to 10 stories maximum on the main page
                            itemCount: controller.stories.length > 10
                                ? 10
                                : controller.stories.length,
                            itemBuilder: (context, index) {
                              final story = controller.stories[index];
                              return Padding(
                                padding: EdgeInsetsDirectional.only(end: 12.w),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => StoryViewPage(
                                        stories: controller.stories,
                                        initialIndex: index,
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF7F22FE),
                                            width: 2,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: story.restaurant.logo,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      SizedBox(
                                        width: 70.w,
                                        child: Text(
                                          story.restaurant.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24.w,
                          top: 16.h,
                          bottom: 8.h,
                        ),
                        child: Row(
                          children: [
                            SvgIcon(
                              iconName: "assets/svg/client/fire.svg",
                              color: const Color(0xFFFFA800),
                              width: 24.w,
                              height: 24.h,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'المميزة',
                              style: const TextStyle().textColorBold(
                                color: const Color(0xFF101727),
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Featured Restaurants (Horizontal)
                      SizedBox(
                        height: 215.h,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = controller.restaurants[index];
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.88,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 12.w),
                                child: RestaurantCard(restaurant: restaurant),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24.w,
                          top: 16.h,
                          bottom: 8.h,
                        ),
                        child: Text(
                          'كُل المطاعم',
                          style: const TextStyle().textColorBold(
                            color: const Color(0xFF101727),
                            fontSize: 18.sp,
                          ),
                        ),
                      ),

                      // All Restaurants (Horizontal with Pagination)
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              controller.hasMore &&
                              !controller.isLoadingMore) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: SizedBox(
                          height: 215.h,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                controller.restaurants.length +
                                (controller.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.restaurants.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final restaurant = controller.restaurants[index];
                              return SizedBox(
                                width: 300.w,
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    end: 12.w,
                                  ),
                                  child: RestaurantCard(restaurant: restaurant),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final dynamic restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = restaurant.isFavorite;
    final bool isActive = restaurant is Restaurant ? restaurant.user.isActive : restaurant.isOpen;
    final String restaurantId = restaurant.id;
    final String name = restaurant.name;
    final String? backgroundImage = restaurant.backgroundImage;
    final double lat = restaurant.lat;
    final double long = restaurant.long;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to restaurant details
          Get.to(() => RestaurantDetailsScreen(restaurantId: restaurantId));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background Image
              if (backgroundImage != null)
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: backgroundImage,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            height: 130,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: CustomIconButtonApp(
                          onTap: () {
                            if (restaurant is Restaurant) {
                              final controller = Get.find<RestaurantsController>();
                              controller.toggleFavorite(restaurant);
                            } else {
                              final controller = Get.find<FavoritesController>();
                              controller.toggleFavorite(restaurant);
                            }
                          },
                          height: 40,
                          width: 40,
                          radius: 20,
                          color: Colors.white.withOpacity(0.7),
                          borderColor: Colors.grey.withOpacity(0.5),
                          childWidget: SvgIcon(
                            iconName: "assets/svg/client/fav.svg",
                            color: isFavorite ? Colors.red : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12.h,
                        left: 12.w,
                        child: CustomButtonApp(
                          onTap: () {},
                          wrapContent: true,
                          borderRadius: 10,
                          height: 22.h,
                          isFill: true,
                          color: Colors.white,
                          borderColor: Colors.grey.withOpacity(0.5),
                          childWidget: Row(
                            children: [
                              SvgIcon(
                                padding: EdgeInsets.only(bottom: 2.h),
                                iconName: "assets/svg/client/star_filled.svg",
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '4.5',
                                style: const TextStyle().textColorBold(
                                  fontSize: 10,
                                  color: const Color(0xFF101727),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isActive)
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            color: const Color(0xB27F22FE),
                            child: Text(
                              'مغلق الأن',
                              textAlign: TextAlign.center,
                              style: const TextStyle().textColorBold(
                                color: Colors.white,
                                fontSize: 20.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              SizedBox(height: 8.h),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Logo and Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name
                        Text(
                          name,
                          style: const TextStyle().textColorBold(
                            fontSize: 16.sp,
                          ),
                        ),
                        if (true)
                          Row(
                            children: [
                              Text(
                                "عرض التوصيل مجاني",
                                style: const TextStyle().textColorBold(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF00A63E),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              SvgIcon(
                                iconName: "assets/svg/client/delivery-bike.svg",
                              ),
                            ],
                          ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    Builder(
                      builder: (context) {
                        if (!Get.isRegistered<RestaurantsController>()) {
                          return const SizedBox();
                        }
                        
                        final controller = Get.find<RestaurantsController>();
                        return Obx(() {
                          final userLat = controller.userLat;
                          final userLong = controller.userLong;

                          String distanceText = '--';
                          String priceText = '--';

                          if (userLat != null && userLong != null) {
                            final distance = LocationUtils.calculateDistance(
                              userLat: userLat,
                              userLong: userLong,
                              restaurantLat: lat,
                              restaurantLong: long,
                            );
                            distanceText = LocationUtils.formatDistance(distance);

                            final price = LocationUtils.calculateDeliveryPrice(
                              distanceInKm: distance,
                            );
                            priceText = LocationUtils.formatPrice(price);
                          }

                          return Row(
                            children: [
                              Text(
                                "التوصيل: $priceText",
                                style: const TextStyle().textColorMedium(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF697282),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Row(
                                children: [
                                  SvgIcon(
                                    iconName: "assets/svg/client/location.svg",
                                    color: const Color(0xFF738DAD),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "المسافة: $distanceText",
                                    style: const TextStyle().textColorMedium(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF697282),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
