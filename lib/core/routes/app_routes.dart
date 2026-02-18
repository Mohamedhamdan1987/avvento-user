class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';

  // Main Routes
  static const String clientNavBar = '/client_nav_bar';
  static const String driverNavBar = '/driver_nav_bar';

  // notifications Routes
  static const String notifications = '/notifications';

  static const String restaurantSupport = '/restaurantSupport';

  // Orders Routes
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String orderTrackingMap = '/order-tracking-map';

  // Profile Routes
  static const String changePassword = '/change-password';
  static const String editAddress = '/edit-address';
  static const String editProfile = '/edit-profile';
  static const String addressList = '/address-list';
  static const String mapSelection = '/map-selection';

  // Restaurants Routes
  static const String restaurants = '/restaurants';

  // Markets Routes
  static const String markets = '/markets';
  static const String marketDetails = '/market-details';
  static const String marketCartDetails = '/market-cart-details';
  static const String marketCheckout = '/market-checkout';

  static const String cartListPage = '/cart-list-page';
  static const String restaurantCartDetails = '/restaurant-cart-details';
  static const String checkout = '/checkout';
  static const String wallet = '/wallet';
  static const String orderSupport = '/order-support';
}
