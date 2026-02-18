import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:avvento/features/client/restaurants/models/best_restaurant_model.dart';
import 'package:avvento/features/client/restaurants/models/favorite_restaurant_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/restaurants_controller.dart';
import '../models/category_selection_model.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../../../core/utils/location_utils.dart';
import '../../address/controllers/address_controller.dart';
import 'story_view_page.dart';
import 'all_stories_page.dart';
import 'restaurant_details_screen.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';

class RestaurantsPage extends GetView<RestaurantsController> {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: AppColors.white,
      // appBar:
      // CustomAppBar(
      //   titleWidget: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Text(
      //         'التوصيل إلى',
      //         style: TextStyle(
      //           color: const Color(0xFF7F22FE),
      //           fontSize: 12,
      //           fontFamily: 'IBM Plex Sans Arabic',
      //           fontWeight: FontWeight.w700,
      //           height: 1.33,
      //         ),
      //       ),
      //       Row(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           Text(
      //             'المنزل - طرابلس',
      //             style: TextStyle(
      //               color: const Color(0xFF101727),
      //               fontSize: 14,
      //               fontFamily: 'IBM Plex Sans Arabic',
      //               fontWeight: FontWeight.w700,
      //               height: 1.43,
      //             ),
      //           ),
      //           SvgIcon(iconName: "assets/svg/arrow_down.svg"),
      //         ],
      //       )
      //     ],
      //   ),
      //    leading: Row(
      //      children: [
      //        // SizedBox(width: 1.w),
      //        CustomIconButtonApp(
      //          color:  Color(0xFFF9FAFB),
      //          childWidget: SvgIcon(
      //            iconName: 'assets/svg/arrow-right.svg',
      //            color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textDark,
      //          ),
      //          onTap: () => Get.back(),
      //        ),
      //      ],
      //    ),
      //    actions: [
      //      CustomIconButtonApp(
      //          color:  Color(0xFFF9FAFB),
      //          childWidget: SvgIcon(
      //            iconName: "assets/svg/wallet/wallet.svg",
      //          ),
      //          onTap: () {
      //            Get.toNamed(AppRoutes.wallet);
      //          }
      //      ),
      //      SizedBox(width: 16.w),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButtonApp(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    childWidget: SvgIcon(
                      iconName: 'assets/svg/arrow-right.svg',
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          AppColors.textDark,
                    ),
                    onTap: () => Get.back(),
                  ),
                  Flexible(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Get.toNamed(AppRoutes.addressList),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'التوصيل إلى',
                              style: TextStyle(
                                color: const Color(0xFF7F22FE),
                                fontSize: 12,
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Obx(
                                    () => Text(
                                      "${addressController.activeAddress.value?.label} - ${addressController.activeAddress.value?.address}",
                                      style: const TextStyle().textColorLight(
                                        fontSize: 12,
                                        color: const Color(0xFF101727),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SvgIcon(iconName: "assets/svg/arrow_down.svg"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomIconButtonApp(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    childWidget: SvgIcon(
                      iconName: "assets/svg/wallet/wallet.svg",
                    ),
                    onTap: () {
                      Get.toNamed(AppRoutes.wallet);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.axis == Axis.vertical &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200 &&
                      controller.hasMore &&
                      !controller.isLoadingMore) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: AppRefreshIndicator(
                  onRefresh: controller.refreshRestaurants,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          onChanged: (value) {
                            // Debounce search
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (value == controller.searchQuery) return;
                                controller.searchRestaurants(value);
                              },
                            );
                          },
                          decoration: InputDecoration(
                            filled: true,
                            // fillColor: Colors.white,
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

                      // Restaurant Stories Section
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24.w,
                          top: 0.h,
                          bottom: 8.h,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgIcon(
                                  iconName:
                                  "assets/svg/client/fire.svg",
                                  color: const Color(0xFFFFA800),
                                  width: 24.w,
                                  height: 24.h,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'ستوري المطاعم',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                    fontSize: 18,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.w700,
                                    height: 1.56,
                                  ).textColorBold(),
                                ),
                              ],
                            ),
                            if (controller.stories.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                        () => AllStoriesPage(
                                      stories: controller.stories,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    end: 24.w,
                                  ),
                                  child: Text(
                                    'مشاهدة الكل',
                                    style:
                                    const TextStyle(
                                      color: Color(0xFF7F22FE),
                                      fontSize: 12,
                                      fontFamily:
                                      'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.w700,
                                      height: 1.33,
                                    ).textColorBold(
                                      color: const Color(
                                        0xFF7F22FE,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Stories List (Horizontal) with gray placeholders to fill remaining space
                      Builder(
                        builder: (context) {
                          final screenWidth = MediaQuery.of(
                            context,
                          ).size.width;
                          // Each story item is ~72.w wide (60.w circle + 12.w padding)
                          final itemWidth = 72.w;
                          final horizontalPadding = 48.w; // 24.w * 2
                          final visibleCount =
                          ((screenWidth - horizontalPadding) /
                              itemWidth)
                              .ceil();
                          final storiesCount =
                          controller.stories.length > 10
                              ? 10
                              : controller.stories.length;
                          final totalCount =
                          storiesCount >= visibleCount
                              ? storiesCount
                              : visibleCount;

                          return SizedBox(
                            height: 100.h,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: storiesCount >= visibleCount
                                  ? null
                                  : const NeverScrollableScrollPhysics(),
                              itemCount: totalCount,
                              itemBuilder: (context, index) {
                                // Real story
                                if (index < storiesCount) {
                                  final storyGroup =
                                  controller.stories[index];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      end: 12.w,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(
                                              () => StoryViewPage(
                                            stories: storyGroup.stories,
                                            initialIndex: 0,
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
                                                color:
                                                storyGroup.allViewed
                                                    ? Colors.grey
                                                    : const Color(
                                                  0xFF7F22FE,
                                                ),
                                                width: 2,
                                              ),
                                            ),
                                            padding:
                                            const EdgeInsets.all(2),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: storyGroup
                                                    .restaurant
                                                    .logo,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (
                                                    context,
                                                    url,
                                                    error,
                                                    ) => const Icon(
                                                  Icons.error,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          SizedBox(
                                            width: 70.w,
                                            child: Text(
                                              storyGroup
                                                  .restaurant
                                                  .name,
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              textAlign:
                                              TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Gray placeholder
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    end: 12.w,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[200]!.withOpacity(0.5),
                                          border: Border.all(
                                            color: Colors.grey[200]!.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Container(
                                        width: 50.w,
                                        height: 10.h,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200]!.withOpacity(0.5),
                                          borderRadius:
                                          BorderRadius.circular(5),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),


                      // Category chips
                      Obx(() {
                        if (controller.isLoadingCategories &&
                            controller.categories.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          height: 40.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: _CategoryChip(
                                  label: 'الكل',
                                  icon: '🍽️',
                                  imageUrl: null,
                                  isSelected:
                                      controller.selectedCategoryId == null,
                                  onTap: () => controller.selectCategory(null),
                                ),
                              ),
                              ...controller.categories.map(
                                (CategorySelection cat) => Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: _CategoryChip(
                                    label: cat.name,
                                    icon: cat.icon,
                                    imageUrl: cat.image,
                                    isSelected:
                                        controller.selectedCategoryId == cat.id,
                                    onTap: () =>
                                        controller.selectCategory(cat.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 8.h),
                      // Restaurants List
                      Obx(() {
                        // Loading state
                        if (controller.isLoading &&
                            controller.restaurants.isEmpty) {
                          return const RestaurantsPageShimmer();
                        }

                        // Error state
                        if (controller.hasError &&
                            controller.restaurants.isEmpty) {
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
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                            if (controller.restaurants.isNotEmpty) ...[
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
                                          color: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.color,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Featured Restaurants (Horizontal - open only)
                                Builder(
                                  builder: (context) {
                                    final openRestaurants = controller
                                        .restaurants
                                        .where((r) => r.isOpen)
                                        .toList();
                                    if (openRestaurants.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return SizedBox(
                                      height: 215.h,
                                      child: ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: openRestaurants.length,
                                        itemBuilder: (context, index) {
                                          final restaurant =
                                              openRestaurants[index];
                                          return SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.88,
                                            child: Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                    end: 12.w,
                                                  ),
                                              child: RestaurantCard(
                                                restaurant: restaurant,
                                                showClosedOverlay: false,
                                                  // color: Theme.of(context).scaffoldBackgroundColor
                                                  color: AppColors.white
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],

                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 24.w,
                                  top: 16.h,
                                  bottom: 8.h,
                                ),
                                child: Text(
                                  'الأكثر شعبية',
                                  style: const TextStyle().textColorBold(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                              // Best Restaurants with gray placeholders to fill remaining space
                              Builder(
                                builder: (context) {
                                  final screenWidth = MediaQuery.of(
                                    context,
                                  ).size.width;
                                  // Each item is ~82.w wide (70 circle + 12.w padding)
                                  final itemWidth = 82.w;
                                  final horizontalPadding = 48.w; // 24.w * 2
                                  final visibleCount =
                                      ((screenWidth - horizontalPadding) /
                                              itemWidth)
                                          .ceil();
                                  final bestCount =
                                      controller.bestRestaurants.length;
                                  final totalCount = bestCount >= visibleCount
                                      ? bestCount
                                      : visibleCount;

                                  return SizedBox(
                                    height: 100.h,
                                    child: ListView.builder(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      physics: bestCount >= visibleCount
                                          ? null
                                          : const NeverScrollableScrollPhysics(),
                                      itemCount: totalCount,
                                      itemBuilder: (context, index) {
                                        // Real restaurant
                                        if (index < bestCount) {
                                          final restaurant =
                                              controller.bestRestaurants[index];
                                          return Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              end: 12.w,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                Get.to(
                                                  () => RestaurantDetailsScreen(
                                                    restaurantId: restaurant.id,
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: ClipOval(
                                                      child: Stack(
                                                        children: [
                                                          CachedNetworkImage(
                                                            imageUrl: restaurant
                                                                .logo!,
                                                            fit: BoxFit.cover,
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => Container(
                                                                  color: Colors
                                                                      .grey[300],
                                                                  child: const Icon(
                                                                    Icons
                                                                        .restaurant,
                                                                    size: 30,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  SizedBox(
                                                    width: 70.w,
                                                    child: Text(
                                                      restaurant.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        // Gray placeholder
                                        return Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            end: 12.w,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[200]!.withOpacity(0.5),
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Container(
                                                width: 50.w,
                                                height: 10.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200]!.withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),

                              if (controller.restaurants.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    start: 24.w,
                                    top: 16.h,
                                    bottom: 8.h,
                                  ),
                                  child: Text(
                                    'كُل المطاعم',
                                    style: const TextStyle().textColorBold(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                                // All Restaurants (Vertical, sorted: open first)
                                Builder(
                                  builder: (context) {
                                    final sorted = [...controller.restaurants]
                                      ..sort((a, b) {
                                        if (a.isOpen == b.isOpen) return 0;
                                        return a.isOpen ? -1 : 1;
                                      });
                                    return Column(
                                      children: [
                                        ...sorted.map(
                                          (restaurant) => Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24.w,
                                              vertical: 6.h,
                                            ),
                                            child: RestaurantCard(
                                              restaurant: restaurant,
                                            ),
                                          ),
                                        ),
                                        if (controller.hasMore)
                                          ShimmerLoading(
                                            child: Column(
                                              children: List.generate(
                                                2,
                                                (_) => const RestaurantCardShimmer(),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],

                              SizedBox(height: 20.h),
                            ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category filter chip (selected = purple, unselected = white).
class _CategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : const Color(0xFF697282);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        constraints: BoxConstraints(minWidth: 88.w, minHeight: 45.h),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF7F22FE) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.76,
              color: isSelected
                  ? const Color(0xFF7F22FE)
                  : Colors.black.withValues(alpha: 0.10),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.category_outlined,
                    size: 24.sp,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
            ] else if (icon != null && icon!.isNotEmpty) ...[
              Text(
                icon!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final dynamic restaurant;
  final bool showClosedOverlay;
    final Color? color;


  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.showClosedOverlay = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = restaurant.isFavorite;
    final bool isActive = restaurant is Restaurant
        ? restaurant.isOpen
        : (restaurant is BestRestaurant
              ? restaurant.isOpen
              : (restaurant is FavoriteRestaurant ? restaurant.isOpen : false));
    final String restaurantId = restaurant.id;
    final String name = restaurant.name;
    final String? backgroundImage = restaurant.backgroundImage;
    final double lat = restaurant.lat;
    final double long = restaurant.long;

    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
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
                              final controller =
                                  Get.find<RestaurantsController>();
                              controller.toggleFavorite(restaurant);
                            } else if (restaurant is BestRestaurant) {
                              final controller =
                                  Get.find<RestaurantsController>();
                              controller.toggleBestRestaurantFavorite(
                                restaurant,
                              );
                            } else {
                              final controller =
                                  Get.find<FavoritesController>();
                              controller.toggleFavorite(restaurant);
                            }
                          },
                          height: 40,
                          width: 40,
                          radius: 20,
                          color: Colors.white.withOpacity(0.7),
                          borderColor: Colors.grey.withOpacity(0.5),
                          childWidget: Icon(
                            (isFavorite) ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color:  AppColors.primary,
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
                      if (!isActive && showClosedOverlay)
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            color: const Color(0x3A7F22FE),
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
                            distanceText = LocationUtils.formatDistance(
                              distance,
                            );

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
