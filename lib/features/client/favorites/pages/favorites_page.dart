import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_app_bar.dart';
import '../../restaurants/pages/restaurants_page.dart';
import '../../markets/models/market_model.dart';
import '../../markets/pages/market_details_page.dart';
import '../controllers/favorites_controller.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is created
    Get.put(FavoritesController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'المفضلة',
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          bottom: TabBar(
            indicatorColor: AppColors.purple,
            labelColor: AppColors.purple,
            unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
            labelStyle: const TextStyle().textColorBold(fontSize: 14),
            unselectedLabelStyle: const TextStyle().textColorMedium(fontSize: 14),
            tabs: const [
              Tab(text: 'المطاعم'),
              Tab(text: 'صيدليات'),
              Tab(text: 'سوبر ماركت'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Restaurants Tab
            KeyedSubtree(
              key: const ValueKey('restaurants_tab'),
              child: _buildRestaurantsTab(context),
            ),
            
            // Pharmacies Tab
            KeyedSubtree(
              key: const ValueKey('pharmacies_tab'),
              child: _buildPlaceholderTab(context, 'لا توجد صيدليات مفضلة'),
            ),
            
            // Supermarkets Tab
            KeyedSubtree(
              key: const ValueKey('supermarkets_tab'),
              child: _buildMarketsTab(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchFavoriteRestaurants,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      }

      if (controller.favoriteRestaurants.isEmpty) {
        return _buildEmptyState(context, 'لا توجد مطاعم مفضلة');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.favoriteRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = controller.favoriteRestaurants[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: RestaurantCard(restaurant: restaurant),
          );
        },
      );
    });
  }

  Widget _buildMarketsTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMarkets) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasMarketsError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.marketsErrorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchFavoriteMarkets,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      }

      if (controller.favoriteMarkets.isEmpty) {
        return _buildEmptyState(context, 'لا توجد متاجر مفضلة');
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: controller.favoriteMarkets.length,
        itemBuilder: (context, index) {
          final market = controller.favoriteMarkets[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _FavoriteMarketCard(
              market: market,
              onRemoveFavorite: () => controller.toggleMarketFavorite(market),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle().textColorMedium(
              fontSize: 16,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(BuildContext context, String message) {
    return _buildEmptyState(context, message);
  }
}

// ─── Favorite Market Card ───────────────────────────────────────────
class _FavoriteMarketCard extends StatelessWidget {
  final Market market;
  final VoidCallback onRemoveFavorite;

  const _FavoriteMarketCard({
    required this.market,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => MarketDetailsPage(marketId: market.id));
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.76,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // Market Logo
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 0.76,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: market.logo != null && market.logo!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: market.logo!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildLogoPlaceholder(),
                        )
                      : _buildLogoPlaceholder(),
                ),
              ),
              SizedBox(width: 12.w),

              // Market Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      market.description.isNotEmpty
                          ? market.description
                          : market.address,
                      style: const TextStyle().textColorMedium(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        // Delivery info
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.sp,
                          color: const Color(0xFF99A1AF),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          market.deliveryTime > 0
                              ? '${market.deliveryTime} د'
                              : '-- د',
                          style: const TextStyle().textColorMedium(
                            fontSize: 12.sp,
                            color: const Color(0xFF99A1AF),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1D5DC),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text(
                          market.deliveryFeeDisplay,
                          style: const TextStyle().textColorMedium(
                            fontSize: 12.sp,
                            color: const Color(0xFF99A1AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite button
              GestureDetector(
                onTap: onRemoveFavorite,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Icon(
        Icons.store_rounded,
        size: 32.sp,
        color: Colors.grey[400],
      ),
    );
  }
}
