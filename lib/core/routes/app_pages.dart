import 'package:avvento/features/client/pages/client_nav_bar.dart';
import 'package:avvento/features/driver/pages/driver_nav_bar.dart';
import 'package:avvento/features/auth/models/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/pages/forget_password_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/otp_verification_page.dart';
import '../../features/auth/pages/reset_password_page.dart';
import '../../features/client/restaurants/bindings/restaurants_binding.dart';
import '../../features/client/restaurants/pages/restaurants_page.dart';
import '../constants/app_constants.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  // Get initial route based on authentication status
  static String getInitialRoute() {
    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);
    final userData = storage.read<Map<String, dynamic>>(AppConstants.userKey);

    // If token and user data exist, go to appropriate main page based on role
    if (token != null && token.isNotEmpty && userData != null) {
      final user = UserModel.fromJson(userData);
      return user.type == 'driver' ? AppRoutes.driverNavBar : AppRoutes.clientNavBar;
    }

    // Otherwise, go to login page
    return AppRoutes.login;
  }

  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgetPasswordPage(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return OtpVerificationPage(
          phone: args?['phone'] ?? '',
          isFromRegister: args?['isFromRegister'] ?? false,
        );
      },
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return ResetPasswordPage(
          userName: args?['userName'] ?? '',
        );
      },
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.clientNavBar,
      page: () => const ClientNavBar(),
      // binding: ClientBinding(), // Define this later if needed
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.driverNavBar,
      page: () => const DriverNavBar(),
      // binding: DriverBinding(), // Define this later if needed
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.restaurants,
      page: () => const RestaurantsPage(),
      binding: RestaurantsBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
