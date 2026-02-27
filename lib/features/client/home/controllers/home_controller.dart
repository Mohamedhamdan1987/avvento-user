import 'package:avvento/features/client/restaurants/models/favorite_restaurant_model.dart';
import 'package:avvento/features/client/markets/services/markets_service.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:avvento/features/client/restaurants/services/restaurants_service.dart';
import 'package:get/get.dart';
import '../models/home_service_item.dart';
import '../models/weekly_offer_model.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();
  final MarketsService _marketsService = MarketsService();
  final HomeService _homeService = HomeService();

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxInt _currentPromoPage = 0.obs;
  final RxList<Restaurant> featuredRestaurants = <Restaurant>[].obs;
  final RxList<FavoriteRestaurant> favoriteRestaurants = <FavoriteRestaurant>[].obs;
  final RxList<WeeklyOffer> weeklyOffers = <WeeklyOffer>[].obs;
  final RxList<HomeServiceItem> homeServices = <HomeServiceItem>[].obs;
  final RxList<HomeRestaurantSectionItem> homeSectionRestaurants =
      <HomeRestaurantSectionItem>[].obs;
  final RxList<HomeMarketSectionItem> homeSectionMarkets =
      <HomeMarketSectionItem>[].obs;
  final RxList<HomeAdvertisementSectionItem> homeSectionAdvertisements =
      <HomeAdvertisementSectionItem>[].obs;
  final RxString _appLogo = ''.obs;
  final RxBool _isRestaurantsSectionEnabled = false.obs;
  final RxBool _isMarketsSectionEnabled = false.obs;
  final RxBool _isAdvertisementsSectionEnabled = false.obs;
  final RxSet<String> _homeFavoriteRestaurantIds = <String>{}.obs;
  final RxSet<String> _homeFavoriteMarketIds = <String>{}.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  int get currentPromoPage => _currentPromoPage.value;
  String get appLogo => _appLogo.value;
  bool get isRestaurantsSectionEnabled => _isRestaurantsSectionEnabled.value;
  bool get isMarketsSectionEnabled => _isMarketsSectionEnabled.value;
  bool get isAdvertisementsSectionEnabled => _isAdvertisementsSectionEnabled.value;

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
        fetchHomeSections(),
        fetchFeaturedRestaurants(),
        fetchFavoriteRestaurants(),
        fetchFavoriteMarketsForHome(),
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
        fetchHomeSections(),
        fetchFeaturedRestaurants(),
        fetchFavoriteRestaurants(),
        fetchFavoriteMarketsForHome(),
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
      final settings = await _homeService.getHomeServices();
      homeServices.assignAll(settings.services);
      _appLogo.value = settings.appLogo;
    } catch (e) {
      print('Error fetching home services: $e');
      homeServices.clear();
      _appLogo.value = '';
    }
  }

  Future<void> fetchHomeSections() async {
    try {
      final sections = await _homeService.getHomeSections();
      _isRestaurantsSectionEnabled.value = sections.restaurantsEnabled;
      _isMarketsSectionEnabled.value = sections.marketsEnabled;
      _isAdvertisementsSectionEnabled.value = sections.advertisementsEnabled;
      homeSectionRestaurants.assignAll(sections.restaurants);
      homeSectionMarkets.assignAll(sections.markets);
      final sortedAds = [...sections.advertisements]
        ..sort((a, b) => a.order.compareTo(b.order));
      homeSectionAdvertisements.assignAll(sortedAds);
    } catch (e) {
      print('Error fetching home sections: $e');
      _isRestaurantsSectionEnabled.value = false;
      _isMarketsSectionEnabled.value = false;
      _isAdvertisementsSectionEnabled.value = false;
      homeSectionRestaurants.clear();
      homeSectionMarkets.clear();
      homeSectionAdvertisements.clear();
    }
  }

  Future<void> fetchFavoriteRestaurants() async {
    try {
      final favorites = await _restaurantsService.getFavoriteRestaurants();
      _homeFavoriteRestaurantIds
        ..clear()
        ..addAll(favorites.map((r) => r.id));
      final openOnly = favorites.where((r) => r.isOpen).toList();
      favoriteRestaurants.assignAll(openOnly);
    } catch (e) {
      print('Error fetching favorite restaurants: $e');
    }
  }

  Future<void> fetchFavoriteMarketsForHome() async {
    try {
      final favorites = await _marketsService.getFavoriteMarkets();
      _homeFavoriteMarketIds
        ..clear()
        ..addAll(favorites.map((m) => m.id));
    } catch (e) {
      print('Error fetching favorite markets for home: $e');
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

  void _setRestaurantFavoriteOptimistic(String restaurantId, bool isFavorite) {
    if (isFavorite) {
      _homeFavoriteRestaurantIds.add(restaurantId);
    } else {
      _homeFavoriteRestaurantIds.remove(restaurantId);
    }
    _homeFavoriteRestaurantIds.refresh();
  }

  void _setMarketFavoriteOptimistic(String marketId, bool isFavorite) {
    if (isFavorite) {
      _homeFavoriteMarketIds.add(marketId);
    } else {
      _homeFavoriteMarketIds.remove(marketId);
    }
    _homeFavoriteMarketIds.refresh();
  }

  Future<void> toggleFavorite(dynamic restaurant) async {
    final String id =
        restaurant is Restaurant ? restaurant.id : (restaurant as FavoriteRestaurant).id;
    final currentIndex = featuredRestaurants.indexWhere((r) => r.id == id);
    final bool oldStatus = currentIndex != -1
        ? featuredRestaurants[currentIndex].isFavorite
        : _homeFavoriteRestaurantIds.contains(id);
    final bool optimisticStatus = !oldStatus;

    // Instant UI update.
    if (currentIndex != -1) {
      final r = featuredRestaurants[currentIndex];
      featuredRestaurants[currentIndex] = r.copyWith(isFavorite: optimisticStatus);
    }
    _setRestaurantFavoriteOptimistic(id, optimisticStatus);

    try {
      final bool newStatus = await _restaurantsService.toggleFavorite(id);

      // Reconcile with backend response.
      if (currentIndex != -1) {
        final r = featuredRestaurants[currentIndex];
        featuredRestaurants[currentIndex] = r.copyWith(isFavorite: newStatus);
      }
      _setRestaurantFavoriteOptimistic(id, newStatus);

      // Keep favorites list in sync.
      await fetchFavoriteRestaurants();
    } catch (e) {
      // Rollback on error.
      if (currentIndex != -1) {
        final r = featuredRestaurants[currentIndex];
        featuredRestaurants[currentIndex] = r.copyWith(isFavorite: oldStatus);
      }
      _setRestaurantFavoriteOptimistic(id, oldStatus);
      print('Error toggling favorite: $e');
    }
  }

  bool isHomeSectionRestaurantFavorite(String restaurantId) {
    return _homeFavoriteRestaurantIds.contains(restaurantId);
  }

  bool isHomeSectionMarketFavorite(String marketId) {
    return _homeFavoriteMarketIds.contains(marketId);
  }

  Future<void> toggleHomeSectionRestaurantFavorite(String restaurantId) async {
    final wasFavorite = _homeFavoriteRestaurantIds.contains(restaurantId);
    _setRestaurantFavoriteOptimistic(restaurantId, !wasFavorite);

    try {
      final isFavorite = await _restaurantsService.toggleFavorite(restaurantId);
      _setRestaurantFavoriteOptimistic(restaurantId, isFavorite);
      await fetchFavoriteRestaurants();
    } catch (e) {
      _setRestaurantFavoriteOptimistic(restaurantId, wasFavorite);
      print('Error toggling home restaurant favorite: $e');
    }
  }

  Future<void> toggleHomeSectionMarketFavorite(String marketId) async {
    final wasFavorite = _homeFavoriteMarketIds.contains(marketId);
    _setMarketFavoriteOptimistic(marketId, !wasFavorite);

    try {
      final isFavorite = await _marketsService.toggleFavorite(marketId);
      _setMarketFavoriteOptimistic(marketId, isFavorite);
    } catch (e) {
      _setMarketFavoriteOptimistic(marketId, wasFavorite);
      print('Error toggling home market favorite: $e');
    }
  }
}
