import 'package:avvento/features/client/pages/client_nav_bar.dart';
import 'package:avvento/features/driver/pages/driver_nav_bar.dart';
import 'package:avvento/features/auth/models/user_model.dart';
import 'package:avvento/features/notifications/presentation/bindings/notifications_binding.dart';
import 'package:avvento/features/notifications/presentation/pages/notifications_page.dart';
import 'package:avvento/features/support/presentation/bindings/support_binding.dart';
import 'package:avvento/features/support/presentation/pages/support_page.dart';
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
import '../../features/client/orders/pages/order_tracking_map_page.dart';
import '../../features/client/orders/widgets/order_tracking_dialog.dart';
import '../../features/client/cart/bindings/cart_binding.dart';
import '../../features/client/cart/pages/cart_list_page.dart';
import '../../features/client/cart/pages/restaurant_cart_details_page.dart';
import '../../features/client/cart/pages/checkout_page.dart';
import '../../features/client/cart/models/cart_model.dart';
import '../../features/client/address/pages/address_list_page.dart';
import '../../features/client/address/pages/map_selection_page.dart';
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

    print("userData: ${userData}");
    // return AppRoutes.driverNavBar;

    // If token and user data exist, go to appropriate main page based on role
    if (token != null && token.isNotEmpty && userData != null) {
      final user = UserModel.fromJson(userData);
      print("user.type: ${user.role}");
      return user.role == 'delivery' ? AppRoutes.driverNavBar : AppRoutes.clientNavBar;
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
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      binding: NotificationsBinding(), // Define this later if needed
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.restaurantSupport,
      page: () => const RestaurantSupportPage(),
      binding: SupportBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.restaurants,
      page: () => const RestaurantsPage(),
      binding: RestaurantsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.orderTrackingMap,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return OrderTrackingMapPage(
          userLat: args['userLat'] as double,
          userLong: args['userLong'] as double,
          restaurantLat: args['restaurantLat'] as double,
          restaurantLong: args['restaurantLong'] as double,
          orderId: args['orderId'] as String,
          status: args['status'] as OrderStatus,
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cartListPage,
      page: () => const CartListPage(),
      binding: CartBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.restaurantCartDetails,
      page: () {
        final cart = Get.arguments as RestaurantCartResponse;
        return RestaurantCartDetailsPage(cart: cart);
      },
      binding: CartBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () {
        final cart = Get.arguments as RestaurantCartResponse;
        return CheckoutPage(cart: cart);
      },
      binding: CartBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addressList,
      page: () => const AddressListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.mapSelection,
      page: () => const MapSelectionPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
