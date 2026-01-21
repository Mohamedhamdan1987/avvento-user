import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/driver_order_model.dart';
import '../models/driver_dashboard_model.dart';

class DriverOrdersService {
  final DioClient _dioClient = DioClient.instance;

  // Get nearby orders for driver
  Future<ApiResponse<List<DriverOrderModel>>> getNearbyOrders({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dioClient.get(
        '/delivery/orders/nearby',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      final ordersData = data['orders'] as List<dynamic>? ?? [];
      final orders = ordersData
          .map((json) => DriverOrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        data: orders,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Get driver's assigned orders
  Future<ApiResponse<List<DriverOrderModel>>> getMyOrders({
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dioClient.get(
        '/delivery/orders/my-orders',
        queryParameters: queryParams,
      );

      final data = response.data;
      final ordersData = data['orders'] as List<dynamic>? ?? [];
      final orders = ordersData
          .map((json) => DriverOrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        data: orders,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Accept an order
  Future<ApiResponse<DriverOrderModel>> acceptOrder(String orderId) async {
    try {
      final response = await _dioClient.post(
        '/delivery/orders/$orderId/take',
      );

      final data = response.data;
      final orderData = data is Map && data.containsKey('order') ? data['order'] : data;
      final order = DriverOrderModel.fromJson(orderData as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        data: order,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Reject an order
  Future<ApiResponse<void>> rejectOrder(String orderId) async {
    try {
      await _dioClient.post(
        '/delivery/orders/$orderId/reject',
      );

      return ApiResponse(
        success: true,
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Update order status
  Future<ApiResponse<DriverOrderModel>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _dioClient.patch(
        '/delivery/orders/$orderId/status',
        data: {'status': status},
      );

      final data = response.data;
      final orderData = data is Map && data.containsKey('order') ? data['order'] : data;
      final order = DriverOrderModel.fromJson(orderData as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        data: order,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }
  // Update driver location
  Future<ApiResponse<void>> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dioClient.patch(
        '/delivery/location',
        data: {
          'lat': latitude,
          'long': longitude,
        },
      );

      return ApiResponse(
        success: true,
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Get driver dashboard data
  Future<ApiResponse<DriverDashboardModel>> getDashboardData() async {
    try {
      final response = await _dioClient.get('/delivery/dashboard');
      final data = response.data;
      final dashboard = DriverDashboardModel.fromJson(data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        data: dashboard,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }
}
