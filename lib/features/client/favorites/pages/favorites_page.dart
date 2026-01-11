import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_app_bar.dart';
import '../../restaurants/pages/restaurants_page.dart';
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
        backgroundColor: AppColors.lightBackground,
        appBar: CustomAppBar(
          title: 'المفضلة',
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: AppColors.purple,
            labelColor: AppColors.purple,
            unselectedLabelColor: AppColors.textLight,
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
              child: _buildRestaurantsTab(),
            ),
            
            // Pharmacies Tab
            KeyedSubtree(
              key: const ValueKey('pharmacies_tab'),
              child: _buildPlaceholderTab('لا توجد صيدليات مفضلة'),
            ),
            
            // Supermarkets Tab
            KeyedSubtree(
              key: const ValueKey('supermarkets_tab'),
              child: _buildPlaceholderTab('لا توجد سوبر ماركت مفضلة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsTab() {
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
        return _buildEmptyState('لا توجد مطاعم مفضلة');
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: AppColors.textPlaceholder),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle().textColorMedium(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String message) {
    return _buildEmptyState(message);
  }
}
