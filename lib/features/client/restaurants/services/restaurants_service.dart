import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/restaurant_model.dart';
import '../models/story_model.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/sub_category_model.dart';
import '../../cart/models/cart_model.dart';
import '../models/favorite_restaurant_model.dart';
import '../models/best_restaurant_model.dart';
import '../models/restaurant_schedule_model.dart';
import '../models/category_selection_model.dart';

class RestaurantsService {
  final DioClient _dioClient = DioClient.instance;

  /// Fetch categories for selection (filter chips)
  Future<List<CategorySelection>> getCategoriesSelection() async {
    try {
      final response = await _dioClient.get('/categories/selection');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => CategorySelection.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurants by category with pagination
  Future<RestaurantsResponse> getRestaurantsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/restaurants/category/$categoryId',
        queryParameters: {'page': page, 'limit': limit},
      );
      final responseData = response.data as Map<String, dynamic>;
      return RestaurantsResponse.fromJson(responseData);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurants with pagination and search
  Future<RestaurantsResponse> getRestaurants({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _dioClient.get(
        '/restaurants',
        queryParameters: queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      return RestaurantsResponse.fromJson(responseData);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch best restaurants
  Future<List<BestRestaurant>> getBestRestaurants({
    int page = 1,
    int limit = 10,
    int minRating = 0,
    int minRatingsCount = 1,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        'minRating': minRating,
        'minRatingsCount': minRatingsCount,
      };

      final response = await _dioClient.get(
        '/restaurants/best',
        queryParameters: queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      // Based on JSON structure: { "restaurants": [...] }
      final list = (responseData['restaurants'] as List<dynamic>)
          .map((e) => BestRestaurant.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException {
      rethrow;
    }
  }

  /// Fetch favorite restaurants
  Future<List<FavoriteRestaurant>> getFavoriteRestaurants() async {
    try {
      final response = await _dioClient.get('/restaurants/favorites/my');
      final responseData = response.data as List<dynamic>;
      return responseData
          .map(
            (item) => FavoriteRestaurant.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant details by ID
  Future<Restaurant> getRestaurantDetails(String restaurantId) async {
    try {
      final response = await _dioClient.get('/restaurants/$restaurantId');
      return Restaurant.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant categories
  Future<List<MenuCategory>> getMenuCategories(String restaurantId) async {
    // try {
    final response = await _dioClient.get(
      '/menu/restaurants/$restaurantId/categories',
    );

    final responseData = response.data as List<dynamic>;
    return responseData
        .map((item) => MenuCategory.fromJson(item as Map<String, dynamic>))
        .toList();
    // } on DioException {
    //   rethrow;
    // }
  }

  /// Fetch restaurant menu items
  Future<List<MenuItem>> getMenuItems(
    String restaurantId, {
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['categoryId'] = categoryId;
      }
      if (subCategoryId != null && subCategoryId.isNotEmpty) {
        queryParameters['subCategoryId'] = subCategoryId;
      }

      final response = await _dioClient.get(
        '/menu/restaurants/$restaurantId/items',
        queryParameters: queryParameters,
      );

      final responseData = response.data as List<dynamic>;
      return responseData
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch subcategories for a category
  Future<List<SubCategory>> getSubCategories(String categoryId) async {
    try {
      final response = await _dioClient.get(
        '/menu/categories/$categoryId/subcategories',
      );

      final responseData = response.data as List<dynamic>;
      return responseData
          .map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant stories grouped by restaurant
  Future<List<RestaurantStoryGroup>> getStories() async {
    try {
      final response = await _dioClient.get('/stories/restaurants-with-active');

      final responseData = response.data as List<dynamic>;
      return responseData
          .map(
            (item) =>
                RestaurantStoryGroup.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Add item to favorites
  Future<void> addToFavorites(String itemId) async {
    try {
      await _dioClient.post('/cart/favorites/$itemId');
    } on DioException {
      rethrow;
    }
  }

  /// Remove item from favorites
  Future<void> removeFromFavorites(String itemId) async {
    try {
      await _dioClient.delete('/cart/favorites/$itemId');
    } on DioException {
      rethrow;
    }
  }

  /// Check if item is favorite
  Future<bool> isFavorite(String itemId) async {
    try {
      final response = await _dioClient.get('/cart/favorites/check/$itemId');
      return response.data['isFavorite'] as bool? ?? false;
    } on DioException {
      return false;
    }
  }

  /// Toggle restaurant favorite status
  Future<bool> toggleFavorite(String restaurantId) async {
    try {
      final response = await _dioClient.post(
        '/restaurants/$restaurantId/favorite',
      );
      return response.data['isFavorite'] as bool? ?? false;
    } on DioException {
      rethrow;
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required String itemId,
    required int quantity,
    required List<String> selectedVariations,
    required List<String> selectedAddOns,
    String? notes,
  }) async {
    try {
      await _dioClient.post(
        '/cart/items',
        data: {
          'itemId': itemId,
          'quantity': quantity,
          'selectedVariations': selectedVariations,
          'selectedAddOns': selectedAddOns,
          'notes': notes ?? '',
        },
      );
    } on DioException {
      rethrow;
    }
  }

  /// Fetch all carts for the current user
  Future<List<RestaurantCartResponse>> getAllCarts() async {
    try {
      final response = await _dioClient.get('/cart/all');
      final responseData = response.data as List<dynamic>;
      return responseData
          .map(
            (item) =>
                RestaurantCartResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch a specific restaurant's cart
  Future<RestaurantCartResponse> getRestaurantCart(String restaurantId) async {
    try {
      final response = await _dioClient.get('/cart/restaurant/$restaurantId');
      return RestaurantCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<RestaurantCartResponse> updateCartItem({
    required String restaurantId,
    required int itemIndex,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.patch(
        '/cart/restaurant/$restaurantId/items/$itemIndex',
        data: {'quantity': quantity, if (notes != null) 'notes': notes},
      );
      return RestaurantCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Remove item from cart
  Future<RestaurantCartResponse> removeCartItem(
    String restaurantId,
    int itemIndex,
  ) async {
    try {
      final response = await _dioClient.delete(
        '/cart/restaurant/$restaurantId/items/$itemIndex',
      );
      return RestaurantCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Clear entire cart for a restaurant
  Future<void> clearCart(String restaurantId) async {
    try {
      await _dioClient.delete('/cart/restaurant/$restaurantId/clear');
    } on DioException {
      rethrow;
    }
  }

  /// Love a story
  Future<Map<String, dynamic>> loveStory(String storyId) async {
    try {
      final response = await _dioClient.post('/stories/$storyId/love');
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant drinks
  Future<List<MenuItem>> getDrinks(String restaurantId) async {
    try {
      final response = await _dioClient.get(
        '/drinks/restaurants/$restaurantId',
      );
      final responseData = response.data as List<dynamic>;
      return responseData
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// View a story
  Future<void> viewStory(String storyId) async {
    try {
      await _dioClient.post('/stories/$storyId/view');
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant schedule
  Future<RestaurantSchedule> getRestaurantSchedule(String restaurantId) async {
    try {
      final response = await _dioClient.get(
        '/restaurants/$restaurantId/schedule',
      );
      return RestaurantSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Reply to a story
  Future<Map<String, dynamic>> replyToStory(
    String storyId,
    String message,
  ) async {
    try {
      final response = await _dioClient.post(
        '/stories/$storyId/reply',
        data: {'message': message},
      );
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    }
  }
}
