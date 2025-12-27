class ApiConstants {
  ApiConstants._();

  // Base URL - يجب تحديثها حسب بيئة العمل
  static const String baseUrl = 'https://api.example.com';
  
  // API Endpoints
  static const String apiVersion = '/api/v1';
  
  // Common Endpoints
  static String get baseApiUrl => '$baseUrl$apiVersion';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  
  // Auth Headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
}

