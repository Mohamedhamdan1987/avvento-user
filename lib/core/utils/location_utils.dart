import 'dart:math';

/// Utility class for location-based calculations
class LocationUtils {
  /// Price per kilometer for delivery (in Dirhams)
  static const double pricePerKm = 5.0;

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  /// 
  /// [userLat] - User's latitude
  /// [userLong] - User's longitude
  /// [restaurantLat] - Restaurant's latitude
  /// [restaurantLong] - Restaurant's longitude
  static double calculateDistance({
    required double userLat,
    required double userLong,
    required double restaurantLat,
    required double restaurantLong,
  }) {
    // Earth's radius in kilometers
    const double earthRadiusKm = 6371.0;

    // Convert degrees to radians
    double lat1Rad = _degreesToRadians(userLat);
    double lat2Rad = _degreesToRadians(restaurantLat);
    double deltaLatRad = _degreesToRadians(restaurantLat - userLat);
    double deltaLongRad = _degreesToRadians(restaurantLong - userLong);

    // Haversine formula
    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * 
        sin(deltaLongRad / 2) * sin(deltaLongRad / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    // Distance in kilometers
    double distance = earthRadiusKm * c;
    
    return distance;
  }

  /// Calculate delivery price based on distance
  /// Returns price in Dirhams
  /// 
  /// [distanceInKm] - Distance in kilometers
  /// [pricePerKilometer] - Optional custom price per kilometer (defaults to 5.0)
  static double calculateDeliveryPrice({
    required double distanceInKm,
    double? pricePerKilometer,
  }) {
    final double price = pricePerKilometer ?? pricePerKm;
    return distanceInKm * price;
  }

  /// Format distance for display
  /// Returns formatted string like "2.5 km" or "500 m"
  /// 
  /// [distanceInKm] - Distance in kilometers
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      // Convert to meters if less than 1 km
      int meters = (distanceInKm * 1000).round();
      return '$meters م';
    } else {
      // Show in kilometers with 1 decimal place
      return '${distanceInKm.toStringAsFixed(1)} كم';
    }
  }

  /// Format price for display
  /// Returns formatted string like "25.0 دينار"
  /// 
  /// [price] - Price in Dirhams
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(1)} دينار';
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
