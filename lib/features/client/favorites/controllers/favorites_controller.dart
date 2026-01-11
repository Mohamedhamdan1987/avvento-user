import 'package:get/get.dart';
import '../../restaurants/models/favorite_restaurant_model.dart';
import '../../restaurants/services/restaurants_service.dart';

class FavoritesController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();

  // Observable state
  final RxList<FavoriteRestaurant> _favoriteRestaurants = <FavoriteRestaurant>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<FavoriteRestaurant> get favoriteRestaurants => _favoriteRestaurants;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteRestaurants();
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

      Get.snackbar(
        'نجاح',
        isFavorite ? 'تمت إضافة المطعم إلى المفضلة' : 'تمت إزالة المطعم من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحديث الحالة المفضلة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
