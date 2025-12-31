import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../../constants/app_constants.dart';
import '../../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token to headers if available
    final token = _storage.read<String>(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - Clear token and redirect to login
    // Don't redirect for login/register endpoints (they return 401 for invalid credentials)
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      final isAuthEndpoint = path.contains('/api/auth/login') || 
                            path.contains('/api/auth/register');
      
      if (!isAuthEndpoint) {
        // Clear stored authentication data
        _storage.remove(AppConstants.tokenKey);
        _storage.remove(AppConstants.userKey);
        
        // Redirect to login page and clear navigation stack
        Get.offAllNamed(AppRoutes.login);
      }
    }

    super.onError(err, handler);
  }
}

