import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/restaurant_model.dart';
import '../models/best_restaurant_model.dart';
import '../models/story_model.dart';
import '../models/category_selection_model.dart';
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

  // Best Restaurants state
  final RxList<BestRestaurant> _bestRestaurants = <BestRestaurant>[].obs;
  final RxBool _isLoadingBest = false.obs;

  // Stories observable state
  final RxList<RestaurantStoryGroup> _stories = <RestaurantStoryGroup>[].obs;
  final RxBool _isLoadingStories = false.obs;

  // Categories for selection (filter chips)
  final RxList<CategorySelection> _categories = <CategorySelection>[].obs;
  final Rx<String?> _selectedCategoryId = Rx<String?>(null);
  final RxBool _isLoadingCategories = false.obs;


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

  // Best Restaurants getters
  List<BestRestaurant> get bestRestaurants => _bestRestaurants;
  bool get isLoadingBest => _isLoadingBest.value;
  double? get userLat => _userLat.value;
  double? get userLong => _userLong.value;

  // Stories getters
  List<RestaurantStoryGroup> get stories => _stories;
  bool get isLoadingStories => _isLoadingStories.value;

  // Categories getters
  List<CategorySelection> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId.value;
  bool get isLoadingCategories => _isLoadingCategories.value;


  @override
  void onInit() {
    super.onInit();
    // Default location (Tripoli) for testing
    _userLat.value = 32.8872;
    _userLong.value = 13.1913;

    Future.microtask(() {
      fetchCategories();
      fetchRestaurants();
      fetchBestRestaurants();
      fetchStories();
    });
  }

  /// Fetch categories for filter chips
  Future<void> fetchCategories() async {
    try {
      _isLoadingCategories.value = true;
      final list = await _restaurantsService.getCategoriesSelection();
      _categories.assignAll(list);
    } catch (e) {
      print('Failed to fetch categories: $e');
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  /// Select category (null = "الكل" / all)
  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId.value == categoryId) return;
    _selectedCategoryId.value = categoryId;
    _currentPage.value = 1;
    await fetchRestaurants(refresh: true);
  }

  /// Fetch best restaurants
  Future<void> fetchBestRestaurants() async {
    try {
      _isLoadingBest.value = true;
      final restaurants = await _restaurantsService.getBestRestaurants();
      _bestRestaurants.assignAll(restaurants);
    } catch (e) {
      print('Failed to fetch best restaurants: $e');
    } finally {
      _isLoadingBest.value = false;
    }
  }

  /// Fetch stories
  Future<void> fetchStories() async {
    try {
      _isLoadingStories.value = true;
      final stories = await _restaurantsService.getStories();
      _stories.assignAll(stories);
    } catch (e) {
      // Silently fail for now or log error
      print('Failed to fetch stories: $e');
    } finally {
      _isLoadingStories.value = false;
    }
  }

  /// Fetch restaurants (initial load or refresh)
  Future<void> fetchRestaurants({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final RestaurantsResponse response;
      final categoryId = _selectedCategoryId.value;
      if (categoryId != null && categoryId.isNotEmpty) {
        response = await _restaurantsService.getRestaurantsByCategory(
          categoryId,
          page: _currentPage.value,
          limit: 10,
        );
      } else {
        response = await _restaurantsService.getRestaurants(
          page: _currentPage.value,
          limit: 10,
          search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
        );
      }

      _restaurants.assignAll(response.data);

      _totalPages.value = response.pagination.totalPages;
      _currentPage.value = response.pagination.page;
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المطاعم: ${e.toString()}';
      showSnackBar(message: _errorMessage.value, isError: true);
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
      final categoryId = _selectedCategoryId.value;

      final RestaurantsResponse response;
      if (categoryId != null && categoryId.isNotEmpty) {
        response = await _restaurantsService.getRestaurantsByCategory(
          categoryId,
          page: nextPage,
          limit: 10,
        );
      } else {
        response = await _restaurantsService.getRestaurants(
          page: nextPage,
          limit: 10,
          search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
        );
      }

      _restaurants.addAll(response.data);
      _totalPages.value = response.pagination.totalPages;
      _currentPage.value = response.pagination.page;
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المزيد من المطاعم: ${e.toString()}';
      showSnackBar(message: _errorMessage.value, isError: true);
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
      fetchBestRestaurants(),
      fetchStories(),
      fetchCategories(),
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
        _restaurants[index] = restaurant.copyWith(
          isFavorite: !restaurant.isFavorite,
        );
        _restaurants.refresh();
      }

      final isFavorite = await _restaurantsService.toggleFavorite(
        restaurant.id,
      );

      // Update with actual result from server
      if (index != -1) {
        _restaurants[index] = _restaurants[index].copyWith(
          isFavorite: isFavorite,
        );
        _restaurants.refresh();
      }

      showSnackBar(
        title: 'نجاح',
        message: isFavorite
            ? 'تمت إضافة المطعم إلى المفضلة'
            : 'تمت إزالة المطعم من المفضلة',
        isSuccess: true,
      );
    } catch (e) {
      // Revert on error
      final index = _restaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _restaurants[index] = restaurant;
        _restaurants.refresh();
      }

      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحديث الحالة المفضلة',
        isError: true,
      );
    }
  }

  /// Toggle best restaurant favorite status
  Future<void> toggleBestRestaurantFavorite(BestRestaurant restaurant) async {
    try {
      // Optimistic update
      final index = _bestRestaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _bestRestaurants[index] = restaurant.copyWith(
          isFavorite: !restaurant.isFavorite,
        );
        _bestRestaurants.refresh();
      }

      final isFavorite = await _restaurantsService.toggleFavorite(
        restaurant.id,
      );

      // Update with actual result from server
      if (index != -1) {
        _bestRestaurants[index] = _bestRestaurants[index].copyWith(
          isFavorite: isFavorite,
        );
        _bestRestaurants.refresh();
      }

      showSnackBar(
        title: 'نجاح',
        message: isFavorite
            ? 'تمت إضافة المطعم إلى المفضلة'
            : 'تمت إزالة المطعم من المفضلة',
        isSuccess: true,
      );
    } catch (e) {
      // Revert on error
      final index = _bestRestaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _bestRestaurants[index] = restaurant;
        _bestRestaurants.refresh();
      }

      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحديث الحالة المفضلة',
        isError: true,
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

  /// Reply to a story
  Future<bool> replyToStory(String storyId, String message) async {
    try {
      await _restaurantsService.replyToStory(storyId, message);
      showSnackBar(
        title: 'نجاح',
        message: 'تم إرسال الرد بنجاح',
        isSuccess: true,
      );
      return true;
    } catch (e) {
      showSnackBar(title: 'خطأ', message: 'فشل إرسال الرد', isError: true);
      return false;
    }
  }
}
