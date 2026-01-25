import '../enums/order_status.dart';
class AppConstants {
  // App Info
  static const String appName = 'We Pay';
  static const String appVersion = '1.0.0';

  // API Configuration
  // static const String baseUrl = 'https://avvento-server.onrender.com/';
  static const String baseUrl = 'http://localhost:3000/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Order Statuses
  static List<Map<String, dynamic>> get statuses => [
    {'label': 'الكل', 'value': null},
    ...OrderStatus.values.map((status) => {
      'label': status.label,
      'value': status.value,
    }),
  ];

  // Error Messages
  static const String networkErrorMessage = 'تحقق من اتصالك بالإنترنت';
  static const String timeoutErrorMessage = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
  static const String serverErrorMessage = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
  static const String unauthorizedErrorMessage = 'غير مصرح لك بالوصول';
  static const String invalidCredentialsErrorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع';
}

