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
import '../../../../core/utils/location_utils.dart';
import 'story_view_page.dart';

class RestaurantsPage extends GetView<RestaurantsController> {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المطاعم'),
        centerTitle: true,
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
                hintText: 'ابحث عن مطعم...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.isEmpty) return const SizedBox();
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearSearch,
                  );
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Restaurants List
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading && controller.restaurants.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
                      Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مطاعم',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
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
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: 24.w, top: 16.h, bottom: 8.h),
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
                                SizedBox(width: 4.w,),
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
                            Padding(
                              padding: EdgeInsetsDirectional.only(end: 24.w),
                              child: Text(
                                'مشاهدة الكل',
                                style: const TextStyle(
                                  color: Color(0xFF7F22FE),
                                  fontSize: 12,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w700,
                                  height: 1.33,
                                ).textColorBold(color: const Color(0xFF7F22FE)),
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
                            itemCount: controller.stories.length,
                            itemBuilder: (context, index) {
                              final story = controller.stories[index];
                              return Padding(
                                padding: EdgeInsetsDirectional.only(end: 12.w),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => StoryViewPage(
                                      stories: controller.stories,
                                      initialIndex: index,
                                    ));
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
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
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
                        padding:  EdgeInsetsDirectional.only(start: 24.w, top: 16.h, bottom: 8.h),
                        child: Row(
                          children: [
                            SvgIcon(
                              iconName: "assets/svg/client/fire.svg",
                              color: const Color(0xFFFFA800),
                              width: 24.w,
                              height: 24.h,
                            ),
                            SizedBox(width: 4.w,),
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
                        height: 285.h,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = controller.restaurants[index];
                            return SizedBox(
                              width: 300.w,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 12.w),
                                child: RestaurantCard(restaurant: restaurant),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding:  EdgeInsetsDirectional.only(start: 24.w, top: 16.h, bottom: 8.h),
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
                          height: 285.h,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.restaurants.length +
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
                                  padding: EdgeInsetsDirectional.only(end: 12.w),
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
  final Restaurant restaurant;

  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to restaurant details
          // Get.toNamed('/restaurant-details', arguments: restaurant);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background Image
              if (restaurant.backgroundImage != null)
                ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      CachedNetworkImage(imageUrl:
                        restaurant.backgroundImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      PositionedDirectional(
                        top: 12.h,
                        start: 12.w,
                        child: CustomIconButtonApp(
                          onTap: () {
                            // Handle favorite toggle
                          },
                          height: 40,
                          width: 40,
                          radius: 20,
                          color: Colors.white.withOpacity(0.7),
                          borderColor: Colors.grey.withOpacity(0.5),
                          childWidget: SvgIcon(
                            iconName: "assets/svg/client/fav.svg",
                            color: true ? null : Colors.white,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 12.h,
                        end: 12.w,
                        child: CustomButtonApp(
                          onTap: () {
                            // Handle favorite toggle
                          },
                          wrapContent: true,
                          borderRadius: 10,
                          height: 22.h,
                          // padding: EdgeInsets.symmetric(vertical: 4.h),
                          isFill: true,
                          color: Colors.white,
                          borderColor: Colors.grey.withOpacity(0.5),
                          childWidget: Row(
                            children: [
                              SvgIcon(
                                padding: EdgeInsets.only(bottom: 2.h,),
                                iconName: "assets/svg/client/star_filled.svg",
                              ),
                              SizedBox(width: 4.w,),
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
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Logo and Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name
                        Text(
                          restaurant.name,
                          style: const TextStyle().textColorBold(
                            fontSize: 16.sp,
                          ),
                        ),
                        if(true)
                        Row(
                          children: [
                            Text(
                              "عرض التوصيل مجاني",
                              style: const TextStyle().textColorBold(
                                fontSize: 10.sp,
                                color: const Color(0xFF00A63E),
                              ),

                            ),
                            SizedBox(width: 4.w,),
                            SvgIcon(
                              iconName: "assets/svg/client/delivery-bike.svg",
                            ),
                          ],
                        ),
                      ],
                    ),

                     SizedBox(height: 8.h),

                    Obx(() {
                      final controller = Get.find<RestaurantsController>();
                      final userLat = controller.userLat;
                      final userLong = controller.userLong;
                      
                      String distanceText = '--';
                      String priceText = '--';
                      
                      if (userLat != null && userLong != null) {
                        final distance = LocationUtils.calculateDistance(
                          userLat: userLat,
                          userLong: userLong,
                          restaurantLat: restaurant.lat,
                          restaurantLong: restaurant.long,
                        );
                        distanceText = LocationUtils.formatDistance(distance);
                        
                        final price = LocationUtils.calculateDeliveryPrice(distanceInKm: distance);
                        priceText = LocationUtils.formatPrice(price);
                      }

                      return Row(
                        children: [
                          Text(
                            "التوصيل: $priceText",
                            style: const TextStyle().textColorMedium(
                              fontSize: 10.sp,
                              color: const Color(0xFF697282)
                            ),
                          ),
                          SizedBox(width: 8.w,),
                          Row(
                            children: [
                              SvgIcon(
                                iconName: "assets/svg/client/location.svg",
                                color: const Color(0xFF738DAD),
                              ),
                              SizedBox(width: 2.w,),
                              Text(
                                "المسافة: $distanceText",
                                style: const TextStyle().textColorMedium(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF697282)
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),


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
