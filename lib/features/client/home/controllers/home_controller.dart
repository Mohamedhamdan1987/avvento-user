import 'package:avvento/features/client/restaurants/models/favorite_restaurant_model.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:avvento/features/client/restaurants/services/restaurants_service.dart';
import 'package:get/get.dart';
import '../models/home_service_item.dart';
import '../models/weekly_offer_model.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();
  final HomeService _homeService = HomeService();

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxInt _currentPromoPage = 0.obs;
  final RxList<Restaurant> featuredRestaurants = <Restaurant>[].obs;
  final RxList<FavoriteRestaurant> favoriteRestaurants = <FavoriteRestaurant>[].obs;
  final RxList<WeeklyOffer> weeklyOffers = <WeeklyOffer>[].obs;
  final RxList<HomeServiceItem> homeServices = <HomeServiceItem>[].obs;

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
        fetchHomeServices(),
        fetchFeaturedRestaurants(),
        fetchFavoriteRestaurants(),
        fetchWeeklyOffers(),
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
        fetchHomeServices(),
        fetchFeaturedRestaurants(),
        fetchFavoriteRestaurants(),
        fetchWeeklyOffers(),
      ]);
    } catch (e) {
      print('Error refreshing home data: $e');
    }
  }

  Future<void> fetchFeaturedRestaurants() async {
    try {
      final response = await _restaurantsService.getRestaurants(limit: 5);
      final openOnly = response.data.where((r) => r.isOpen).toList();
      featuredRestaurants.assignAll(openOnly);
    } catch (e) {
      print('Error fetching featured restaurants: $e');
    }
  }

  Future<void> fetchHomeServices() async {
    try {
      final services = await _homeService.getHomeServices();
      homeServices.assignAll(services);
    } catch (e) {
      print('Error fetching home services: $e');
      homeServices.clear();
    }
  }

  Future<void> fetchFavoriteRestaurants() async {
    try {
      final favorites = await _restaurantsService.getFavoriteRestaurants();
      final openOnly = favorites.where((r) => r.isOpen).toList();
      favoriteRestaurants.assignAll(openOnly);
    } catch (e) {
      print('Error fetching favorite restaurants: $e');
    }
  }

  Future<void> fetchWeeklyOffers() async {
    try {
      final offers = await _homeService.getActiveWeeklyOffers();
      offers.sort((a, b) => a.order.compareTo(b.order));
      weeklyOffers.assignAll(offers);
    } catch (e) {
      print('Error fetching weekly offers: $e');
      weeklyOffers.clear();
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
