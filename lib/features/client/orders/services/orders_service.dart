import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
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

  /// Create a market order
  Future<Map<String, dynamic>> createMarketOrder({
    required String marketId,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLong,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post('/orders/market', data: {
        'marketId': marketId,
        'deliveryAddress': deliveryAddress,
        'deliveryLat': deliveryLat,
        'deliveryLong': deliveryLong,
        'paymentMethod': paymentMethod,
        'notes': notes ?? '',
      });

      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    }
  }

  Future<PaymentInitiationResponse> initiatePayment({
    required double amount,
    required String phone,
    required String email,
    required String customRef,
  }) async {
    try {
      final response = await _dioClient.post('/payment/initiate', data: {
        'amount': amount,
        'phone': phone,
        'email': email,
        'backendUrl': '${AppConstants.baseUrl}payment/webhook',
        'frontendUrl': '${AppConstants.baseUrl}payment/success',
        'customRef': customRef,
      });
      return PaymentInitiationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Reorder a previous order
  Future<OrderModel> reorder(String orderId) async {
    try {
      final response = await _dioClient.post('/orders/$orderId/reorder');
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
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

class PaymentInitiationResponse {
  final bool success;
  final String paymentUrl;
  final String customRef;

  PaymentInitiationResponse({
    required this.success,
    required this.paymentUrl,
    required this.customRef,
  });

  factory PaymentInitiationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationResponse(
      success: json['success'] as bool? ?? false,
      paymentUrl: json['paymentUrl'] as String? ?? '',
      customRef: json['customRef'] as String? ?? '',
    );
  }
}
