import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../features/auth/models/user_model.dart';
import '../constants/app_constants.dart';
import '../routes/app_routes.dart';

/// Middleware to check authentication status and redirect accordingly
class AuthMiddleware extends GetMiddleware {
  final GetStorage _storage = GetStorage();

  @override
  RouteSettings? redirect(String? route) {

    final token = _storage.read<String>(AppConstants.tokenKey);
    final userData = _storage.read<Map<String, dynamic>>(AppConstants.userKey);
    final isAuthenticated =
        token != null && token.isNotEmpty && userData != null;

    // If trying to access auth pages (login, register, forget password) while authenticated
    if (isAuthenticated && _isAuthRoute(route)) {
      final user = UserModel.fromJson(userData);
      return RouteSettings(
        name: user.type == 'driver' ? AppRoutes.driverNavBar : AppRoutes.clientNavBar,
      );
    }

    // If trying to access protected pages without authentication
    if (!isAuthenticated && _isProtectedRoute(route)) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Allow navigation
    return null;
  }

  /// Check if the route is an authentication route
  bool _isAuthRoute(String? route) {
    if (route == null) return false;
    return route == AppRoutes.login ||
        route == AppRoutes.register ||
        route == AppRoutes.forgetPassword;
  }

  /// Check if the route is a protected route (requires authentication)
  bool _isProtectedRoute(String? route) {
    if (route == null) return false;
    return route == AppRoutes.clientNavBar ||
        route == AppRoutes.driverNavBar ||
        route == AppRoutes.changePassword ||
        route == AppRoutes.editAddress ||
        route == AppRoutes.editProfile ||
        route == AppRoutes.orderDetails;
  }
}
