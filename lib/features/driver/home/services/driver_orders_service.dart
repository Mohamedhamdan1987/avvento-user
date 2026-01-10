import 'package:avvento/core/network/api_response.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/driver_order_model.dart';

class DriverOrdersService {
  final Dio _dio = Dio();

  DriverOrdersService() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Get nearby orders for driver
  Future<ApiResponse<List<DriverOrderModel>>> getNearbyOrders({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/driver/nearby-orders',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusKm,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final ordersData = data['data'] as List<dynamic>? ?? [];
          final orders = ordersData
              .map((json) => DriverOrderModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse(
            success: true,
            data: orders,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message']?.toString() ?? 'فشل في جلب الطلبات',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'خطأ في الاتصال بالخادم',
        );
      }
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

      final response = await _dio.get(
        '/api/driver/my-orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final ordersData = data['data'] as List<dynamic>? ?? [];
          final orders = ordersData
              .map((json) => DriverOrderModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return ApiResponse(
            success: true,
            data: orders,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message']?.toString() ?? 'فشل في جلب الطلبات',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'خطأ في الاتصال بالخادم',
        );
      }
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
      final response = await _dio.post(
        '/api/driver/orders/$orderId/accept',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final orderData = data['data'] as Map<String, dynamic>;
          final order = DriverOrderModel.fromJson(orderData);
          return ApiResponse(
            success: true,
            data: order,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message']?.toString() ?? 'فشل في قبول الطلب',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'خطأ في الاتصال بالخادم',
        );
      }
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
      final response = await _dio.post(
        '/api/driver/orders/$orderId/reject',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: null,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message']?.toString() ?? 'فشل في رفض الطلب',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'خطأ في الاتصال بالخادم',
        );
      }
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
      final response = await _dio.patch(
        '/api/driver/orders/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final orderData = data['data'] as Map<String, dynamic>;
          final order = DriverOrderModel.fromJson(orderData);
          return ApiResponse(
            success: true,
            data: order,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message']?.toString() ?? 'فشل في تحديث حالة الطلب',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'خطأ في الاتصال بالخادم',
        );
      }
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
