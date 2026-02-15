import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/market_model.dart';
import '../models/market_category_model.dart';
import '../models/market_product_item.dart';
import '../models/market_cart_model.dart';
import '../models/market_schedule_model.dart';
import '../models/advertisement_model.dart';

class MarketsService {
  final DioClient _dioClient = DioClient.instance;

  /// Fetch market categories for filter chips
  Future<List<MarketCategory>> getMarketCategories() async {
    try {
      final response = await _dioClient.get('/products/categories');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => MarketCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch markets with pagination and search
  Future<MarketsResponse> getMarkets({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['categoryId'] = categoryId;
      }

      final response = await _dioClient.get(
        '/markets',
        queryParameters: queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      return MarketsResponse.fromJson(responseData);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch markets by category with pagination
  Future<MarketsResponse> getMarketsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/markets/category/$categoryId',
        queryParameters: {'page': page, 'limit': limit},
      );
      final responseData = response.data as Map<String, dynamic>;
      return MarketsResponse.fromJson(responseData);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch market products by market ID
  Future<MarketProductsResponse> getMarketProducts(
    String marketId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['categoryId'] = categoryId;
      }
      final response = await _dioClient.get(
        '/markets/$marketId/products',
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      return MarketProductsResponse.fromJson(responseData);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch market details by ID
  Future<Market> getMarketDetails(String marketId) async {
    try {
      final response = await _dioClient.get('/markets/$marketId');
      return Market.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch market schedule
  Future<MarketSchedule> getMarketSchedule(String marketId) async {
    try {
      final response = await _dioClient.get('/markets/$marketId/schedule');
      return MarketSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Toggle market favorite status
  Future<bool> toggleFavorite(String marketId) async {
    try {
      final response = await _dioClient.post(
        '/markets/$marketId/favorite',
      );
      return response.data['isFavorite'] as bool? ?? false;
    } on DioException {
      rethrow;
    }
  }

  /// Fetch favorite markets
  Future<List<Market>> getFavoriteMarkets() async {
    try {
      final response = await _dioClient.get('/markets/favorites/my');
      final responseData = response.data as List<dynamic>;
      return responseData
          .map((item) => Market.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch active advertisements
  Future<List<Advertisement>> getActiveAdvertisements() async {
    try {
      final response = await _dioClient.get('/advertisements/active');
      final responseData = response.data as List<dynamic>;
      return responseData
          .map((item) => Advertisement.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  // ─── Cart APIs ──────────────────────────────────────────────────

  /// Add product to market cart
  Future<MarketCartResponse> addProductToCart({
    required String marketId,
    required String marketProductId,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        '/cart/products',
        data: {
          'marketId': marketId,
          'marketProductId': marketProductId,
          'quantity': quantity,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return MarketCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Fetch all market carts for the current user
  Future<List<MarketCartResponse>> getAllMarketCarts() async {
    try {
      final response = await _dioClient.get('/cart/markets');
      final responseData = response.data as List<dynamic>;
      return responseData
          .map((item) =>
              MarketCartResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  /// Fetch a specific market's cart
  Future<MarketCartResponse> getMarketCart(String marketId) async {
    try {
      final response = await _dioClient.get('/cart/market/$marketId');
      return MarketCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Update product quantity in market cart
  Future<MarketCartResponse> updateCartProduct({
    required String marketId,
    required int productIndex,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.patch(
        '/cart/market/$marketId/products/$productIndex',
        data: {
          'quantity': quantity,
          if (notes != null) 'notes': notes,
        },
      );
      return MarketCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Remove product from market cart
  Future<MarketCartResponse> removeCartProduct(
    String marketId,
    int productIndex,
  ) async {
    try {
      final response = await _dioClient.delete(
        '/cart/market/$marketId/products/$productIndex',
      );
      return MarketCartResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Clear entire market cart
  Future<void> clearMarketCart(String marketId) async {
    try {
      await _dioClient.delete('/cart/market/$marketId/clear');
    } on DioException {
      rethrow;
    }
  }
}
