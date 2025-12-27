class AppConstants {
  AppConstants._();

  static const String appName = 'Avvento';
  
  // API Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // Cache
  static const Duration cacheExpirationDuration = Duration(days: 7);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

