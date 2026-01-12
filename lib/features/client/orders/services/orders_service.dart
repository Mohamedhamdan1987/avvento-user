import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';

  class OrdersService {
  final DioClient _dioClient = DioClient.instance;

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
}
