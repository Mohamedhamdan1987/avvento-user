import 'package:get/get.dart';
import '../models/restaurant_model.dart';
import '../models/story_model.dart';
import '../services/restaurants_service.dart';

class RestaurantsController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();

  // Observable state
  final RxList<Restaurant> _restaurants = <Restaurant>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxString _errorMessage = ''.obs;
  
  // Stories observable state
  final RxList<Story> _stories = <Story>[].obs;
  final RxBool _isLoadingStories = false.obs;
  
  // User location (you can update this with actual GPS location)
  final Rx<double?> _userLat = Rx<double?>(null);
  final Rx<double?> _userLong = Rx<double?>(null);

  // Getters
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get searchQuery => _searchQuery.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  String get errorMessage => _errorMessage.value;
  bool get hasMore => _currentPage.value < _totalPages.value;
  bool get hasError => _errorMessage.value.isNotEmpty;
  double? get userLat => _userLat.value;
  double? get userLong => _userLong.value;
  
  // Stories getters
  List<Story> get stories => _stories;
  bool get isLoadingStories => _isLoadingStories.value;

  @override
  void onInit() {
    super.onInit();
    // Default location (Tripoli) for testing
    _userLat.value = 32.8872;
    _userLong.value = 13.1913;
    
    fetchRestaurants();
    fetchStories();
  }

  /// Fetch stories
  Future<void> fetchStories() async {
    // try {
      _isLoadingStories.value = true;
      final stories = await _restaurantsService.getStories();
      _stories.assignAll(stories);
    // } catch (e) {
    //   // Silently fail for now or log error
    //   print('Failed to fetch stories: $e');
    // } finally {
    //   _isLoadingStories.value = false;
    // }
  }

  /// Fetch restaurants (initial load or refresh)
  Future<void> fetchRestaurants({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _restaurantsService.getRestaurants(
        page: _currentPage.value,
        limit: 10,
        search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
      );

      if (refresh) {
        _restaurants.value = response.data;
      } else {
        _restaurants.assignAll(response.data);
      }

      _totalPages.value = response.pagination.totalPages;
      _currentPage.value = response.pagination.page;
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المطاعم: ${e.toString()}';
      Get.snackbar(
        'خطأ',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load more restaurants (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;

    try {
      _isLoadingMore.value = true;
      _errorMessage.value = '';

      final nextPage = _currentPage.value + 1;

      final response = await _restaurantsService.getRestaurants(
        page: nextPage,
        limit: 10,
        search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
      );

      _restaurants.addAll(response.data);
      _totalPages.value = response.pagination.totalPages;
      _currentPage.value = response.pagination.page;
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المزيد من المطاعم: ${e.toString()}';
      Get.snackbar(
        'خطأ',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Search restaurants
  Future<void> searchRestaurants(String query) async {
    _searchQuery.value = query;
    _currentPage.value = 1;
    await fetchRestaurants(refresh: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery.value = '';
    _currentPage.value = 1;
    await fetchRestaurants(refresh: true);
  }

  /// Refresh restaurants (pull to refresh)
  Future<void> refreshRestaurants() async {
    await Future.wait([
      fetchRestaurants(refresh: true),
      fetchStories(),
    ]);
  }

  /// Love a story
  Future<void> loveStory(String storyId) async {
    try {
      await _restaurantsService.loveStory(storyId);
      // Optionally update the local story model if we want immediate feedback without refresh
      // For now, we rely on the API response or refresh if needed.
    } catch (e) {
      print('Failed to love story: $e');
    }
  }

  /// Toggle restaurant favorite status
  Future<void> toggleFavorite(Restaurant restaurant) async {
    try {
      // Optimistic update
      final index = _restaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _restaurants[index] = restaurant.copyWith(isFavorite: !restaurant.isFavorite);
        _restaurants.refresh();
      }

      final isFavorite = await _restaurantsService.toggleFavorite(restaurant.id);
      
      // Update with actual result from server
      if (index != -1) {
        _restaurants[index] = _restaurants[index].copyWith(isFavorite: isFavorite);
        _restaurants.refresh();
      }
      
      Get.snackbar(
        'نجاح',
        isFavorite ? 'تمت إضافة المطعم إلى المفضلة' : 'تمت إزالة المطعم من المفضلة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Revert on error
      final index = _restaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _restaurants[index] = restaurant;
        _restaurants.refresh();
      }
      
      Get.snackbar(
        'خطأ',
        'فشل تحديث الحالة المفضلة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// View a story
  Future<void> viewStory(String storyId) async {
    try {
      await _restaurantsService.viewStory(storyId);
    } catch (e) {
      print('Failed to view story: $e');
    }
  }
}

