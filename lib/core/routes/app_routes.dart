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

  // Orders Routes
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String orderTrackingMap = '/order-tracking-map';

  // Profile Routes
  static const String changePassword = '/change-password';
  static const String editAddress = '/edit-address';
  static const String editProfile = '/edit-profile';

  // Restaurants Routes
  static const String restaurants = '/restaurants';

  // Add more routes here as you add features
  // Example:
  // static const String profile = '/profile';
  // static const String settings = '/settings';
}
