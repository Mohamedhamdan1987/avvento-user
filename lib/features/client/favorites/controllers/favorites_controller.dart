import 'package:get/get.dart';
import '../../restaurants/models/favorite_restaurant_model.dart';
import '../../restaurants/services/restaurants_service.dart';
import '../../markets/models/market_model.dart';
import '../../markets/services/markets_service.dart';
import '../../../../core/utils/show_snackbar.dart';

class FavoritesController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();
  final MarketsService _marketsService = MarketsService();

  // Observable state — Restaurants
  final RxList<FavoriteRestaurant> _favoriteRestaurants = <FavoriteRestaurant>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Observable state — Markets
  final RxList<Market> _favoriteMarkets = <Market>[].obs;
  final RxBool _isLoadingMarkets = false.obs;
  final RxString _marketsErrorMessage = ''.obs;

  // Getters — Restaurants
  List<FavoriteRestaurant> get favoriteRestaurants => _favoriteRestaurants;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  // Getters — Markets
  List<Market> get favoriteMarkets => _favoriteMarkets;
  bool get isLoadingMarkets => _isLoadingMarkets.value;
  String get marketsErrorMessage => _marketsErrorMessage.value;
  bool get hasMarketsError => _marketsErrorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteRestaurants();
    fetchFavoriteMarkets();
  }

  /// Fetch favorite restaurants
  Future<void> fetchFavoriteRestaurants() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      final restaurants = await _restaurantsService.getFavoriteRestaurants();
      _favoriteRestaurants.assignAll(restaurants);
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المطاعم المفضلة: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch favorite markets
  Future<void> fetchFavoriteMarkets() async {
    try {
      _isLoadingMarkets.value = true;
      _marketsErrorMessage.value = '';

      final markets = await _marketsService.getFavoriteMarkets();
      _favoriteMarkets.assignAll(markets);
    } catch (e) {
      _marketsErrorMessage.value = 'فشل تحميل المتاجر المفضلة: ${e.toString()}';
    } finally {
      _isLoadingMarkets.value = false;
    }
  }

  /// Toggle restaurant favorite status
  Future<void> toggleFavorite(FavoriteRestaurant restaurant) async {
    try {
      final isFavorite = await _restaurantsService.toggleFavorite(restaurant.id);
      
      if (!isFavorite) {
        // If removed from favorites, remove from local list
        _favoriteRestaurants.removeWhere((r) => r.id == restaurant.id);
      } else {
        fetchFavoriteRestaurants();
      }

      showSnackBar(
        title: 'نجاح',
        message: isFavorite ? 'تمت إضافة المطعم إلى المفضلة' : 'تمت إزالة المطعم من المفضلة',
        isSuccess: true,
      );
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحديث الحالة المفضلة',
        isError: true,
      );
    }
  }

  /// Toggle market favorite status
  Future<void> toggleMarketFavorite(Market market) async {
    try {
      final isFavorite = await _marketsService.toggleFavorite(market.id);

      if (!isFavorite) {
        _favoriteMarkets.removeWhere((m) => m.id == market.id);
      } else {
        fetchFavoriteMarkets();
      }

      showSnackBar(
        title: 'نجاح',
        message: isFavorite ? 'تمت إضافة المتجر إلى المفضلة' : 'تمت إزالة المتجر من المفضلة',
        isSuccess: true,
      );
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحديث الحالة المفضلة',
        isError: true,
      );
    }
  }
}
