import 'package:avvento/features/client/restaurants/models/favorite_restaurant_model.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:avvento/features/client/restaurants/services/restaurants_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxInt _currentPromoPage = 0.obs;
  final RxList<Restaurant> featuredRestaurants = <Restaurant>[].obs;
  final RxList<FavoriteRestaurant> favoriteRestaurants = <FavoriteRestaurant>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  int get currentPromoPage => _currentPromoPage.value;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      _isLoading.value = true;
      await Future.wait([
        fetchFeaturedRestaurants(),
        fetchFavoriteRestaurants(),
      ]);
    } catch (e) {
      print('Error fetching home data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh data without showing full loading screen (for pull-to-refresh)
  Future<void> refreshData() async {
    try {
      await Future.wait([
        fetchFeaturedRestaurants(),
        fetchFavoriteRestaurants(),
      ]);
    } catch (e) {
      print('Error refreshing home data: $e');
    }
  }

  Future<void> fetchFeaturedRestaurants() async {
    try {
      final response = await _restaurantsService.getRestaurants(limit: 5);
      featuredRestaurants.assignAll(response.data);
    } catch (e) {
      print('Error fetching featured restaurants: $e');
    }
  }

  Future<void> fetchFavoriteRestaurants() async {
    try {
      final favorites = await _restaurantsService.getFavoriteRestaurants();
      favoriteRestaurants.assignAll(favorites);
    } catch (e) {
      print('Error fetching favorite restaurants: $e');
    }
  }

  // Setters
  void setCurrentPromoPage(int index) => _currentPromoPage.value = index;

  Future<void> toggleFavorite(dynamic restaurant) async {
    try {
      final String id = restaurant is Restaurant ? restaurant.id : (restaurant as FavoriteRestaurant).id;
      final bool newStatus = await _restaurantsService.toggleFavorite(id);
      
      // Update local state in featured list if present
      final index = featuredRestaurants.indexWhere((r) => r.id == id);
      if (index != -1) {
        final r = featuredRestaurants[index];
        featuredRestaurants[index] = r.copyWith(isFavorite: newStatus);
      }
      
      // Refresh favorites list
      await fetchFavoriteRestaurants();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
