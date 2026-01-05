import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/restaurant_model.dart';
import '../models/story_model.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/sub_category_model.dart';
import '../../cart/models/cart_model.dart';

class RestaurantsService {
  final DioClient _dioClient = DioClient();

  /// Fetch restaurants with pagination and search
  /// 
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// - [limit]: Number of items per page (default: 10)
  /// - [search]: Search query string (optional)
  Future<RestaurantsResponse> getRestaurants({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Add search parameter if provided
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _dioClient.get(
        '/restaurants',
        queryParameters: queryParameters,
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      return RestaurantsResponse.fromJson(responseData);
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
    try {
      final response = await _dioClient.get('/menu/restaurants/$restaurantId/categories');
      
      final responseData = response.data as List<dynamic>;
      return responseData.map((item) => MenuCategory.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
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
      return responseData.map((item) => MenuItem.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch subcategories for a category
  Future<List<SubCategory>> getSubCategories(String categoryId) async {
    try {
      final response = await _dioClient.get('/menu/categories/$categoryId/subcategories');
      
      final responseData = response.data as List<dynamic>;
      return responseData.map((item) => SubCategory.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant stories
  Future<List<Story>> getStories() async {
    try {
      final response = await _dioClient.get('/stories');
      
      final responseData = response.data as List<dynamic>;
      return responseData.map((item) => Story.fromJson(item as Map<String, dynamic>)).toList();
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

  /// Add item to cart
  Future<void> addToCart({
    required String itemId,
    required int quantity,
    required List<String> selectedVariations,
    required List<String> selectedAddOns,
    String? notes,
  }) async {
    try {
      await _dioClient.post('/cart/items', data: {
        'itemId': itemId,
        'quantity': quantity,
        'selectedVariations': selectedVariations,
        'selectedAddOns': selectedAddOns,
        'notes': notes ?? '',
      });
    } on DioException {
      rethrow;
    }
  }

  /// Fetch all carts for the current user
  Future<List<RestaurantCart>> getAllCarts() async {
    try {
      final response = await _dioClient.get('/cart/all');
      final responseData = response.data as List<dynamic>;
      return responseData.map((item) => RestaurantCart.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch a specific restaurant's cart
  Future<RestaurantCart> getRestaurantCart(String restaurantId) async {
    try {
      final response = await _dioClient.get('/cart/restaurant/$restaurantId');
      return RestaurantCart.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<RestaurantCart> updateCartItem({
    required String restaurantId,
    required int itemIndex,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.patch('/cart/restaurant/$restaurantId/items/$itemIndex', data: {
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      });
      return RestaurantCart.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Remove item from cart
  Future<RestaurantCart> removeCartItem(String restaurantId, int itemIndex) async {
    try {
      final response = await _dioClient.delete('/cart/restaurant/$restaurantId/items/$itemIndex');
      return RestaurantCart.fromJson(response.data as Map<String, dynamic>);
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
}
