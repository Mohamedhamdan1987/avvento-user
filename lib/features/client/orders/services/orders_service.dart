import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';
import '../../cart/models/calculate_price_model.dart';

class OrdersService {
  final DioClient _dioClient = DioClient.instance;

  /// Calculate order price
  Future<CalculatePriceResponse> calculatePrice({
    required String restaurantId,
    required String addressId,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLong,
    required String paymentMethod,
    List<Map<String, dynamic>>? drinks,
  }) async {
    try {
      final response = await _dioClient.post('/orders/calculate-price', data: {
        'restaurantId': restaurantId,
        'addressId': addressId,
        'deliveryAddress': deliveryAddress,
        'deliveryLat': deliveryLat,
        'deliveryLong': deliveryLong,
        'paymentMethod': paymentMethod,
        if (drinks != null) 'drinks': drinks,
      });

      return CalculatePriceResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Create a new order
  /// Create a new order
  Future<OrderModel> createOrder({
    required String restaurantId,
    required String addressId,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLong,
    required String payment,
    String? paymentGatewayTransactionId,
    String? notes,
    List<Map<String, dynamic>>? drinks,
  }) async {
    try {
      final response = await _dioClient.post('/orders', data: {
        'restaurantId': restaurantId,
        'addressId': addressId,
        'deliveryAddress': deliveryAddress,
        'deliveryLat': deliveryLat,
        'deliveryLong': deliveryLong,
        'paymentMethod': payment,
        if (paymentGatewayTransactionId != null)
          'paymentGatewayTransactionId': paymentGatewayTransactionId,
        'notes': notes ?? '',
        if (drinks != null) 'drinks': drinks,
      });

      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch user orders
  Future<OrdersResponse> getUserOrders({int page = 1, int limit = 50}) async {
    try {
      final response = await _dioClient.get('/orders', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return OrdersResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch order details
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      final response = await _dioClient.get('/orders/$orderId');
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Rate a restaurant
  Future<void> rateRestaurant({
    required String restaurantId,
    required int rating,
    required String comment,
    required String orderId,
  }) async {
    try {
      await _dioClient.post('/restaurants/$restaurantId/rate', data: {
        'rating': rating,
        'comment': comment,
        'orderId': orderId,
      });
    } on DioException {
      rethrow;
    }
  }

  /// Rate a driver
  Future<void> rateDriver({
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _dioClient.post('/restaurants/orders/$orderId/rate-driver', data: {
        'rating': rating,
        'comment': comment,
      });
    } on DioException {
      rethrow;
    }
  }
}
