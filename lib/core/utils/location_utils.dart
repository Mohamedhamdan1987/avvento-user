import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for location-based calculations
class LocationUtils {
  /// Price per kilometer for delivery (in Dirhams)
  static const double pricePerKm = 5.0;

  /// Default location (Tripoli) as fallback
  static const double _defaultLat = 32.8872;
  static const double _defaultLong = 13.1913;

  /// Current device location (updated via [init])
  static double _currentLatitude = _defaultLat;
  static double _currentLongitude = _defaultLong;
  static bool _initialized = false;

  /// Getters for current device location
  static double get currentLatitude => _currentLatitude;
  static double get currentLongitude => _currentLongitude;
  static bool get isInitialized => _initialized;

  /// Initialize location — requests permission and fetches current position.
  /// Should be called once at app startup (e.g. in main or a splash screen).
  static Future<void> init() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LocationUtils: Location services are disabled, using default.');
        return;
      }

      // Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('LocationUtils: Location permission denied, using default.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('LocationUtils: Location permission permanently denied, using default.');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;
      _initialized = true;
      print('LocationUtils: Location initialized ($_currentLatitude, $_currentLongitude)');
    } catch (e) {
      print('LocationUtils: Error getting location: $e, using default.');
    }
  }

  /// Refresh the current location (can be called anytime to update)
  static Future<void> refreshLocation() async {
    await init();
  }

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

  /// Calculate estimated delivery time in minutes
  /// Based on distance and average delivery speed
  /// 
  /// [restaurantLat] - Restaurant's latitude
  /// [restaurantLong] - Restaurant's longitude
  /// [deliveryLat] - Delivery address latitude
  /// [deliveryLong] - Delivery address longitude
  /// [averageSpeedKmh] - Average delivery speed in km/h (default: 30 km/h)
  /// [preparationTimeMinutes] - Restaurant preparation time in minutes (default: 15 minutes)
  /// 
  /// Returns estimated delivery time in minutes (rounded to nearest integer)
  static int calculateDeliveryTime({
    required double restaurantLat,
    required double restaurantLong,
    required double deliveryLat,
    required double deliveryLong,
    double averageSpeedKmh = 30.0,
    int preparationTimeMinutes = 15,
  }) {
    // Calculate distance in kilometers
    final distance = calculateDistance(
      userLat: deliveryLat,
      userLong: deliveryLong,
      restaurantLat: restaurantLat,
      restaurantLong: restaurantLong,
    );

    // Calculate travel time in minutes
    // Time = Distance / Speed (convert hours to minutes)
    final travelTimeMinutes = (distance / averageSpeedKmh) * 60;

    // Total time = preparation time + travel time
    final totalTimeMinutes = preparationTimeMinutes + travelTimeMinutes;

    // Round to nearest integer
    return totalTimeMinutes.round();
  }

  /// Format delivery time for display
  /// Returns formatted string like "25 دقيقة" or "1 ساعة"
  /// 
  /// [timeInMinutes] - Time in minutes
  static String formatDeliveryTime(int timeInMinutes) {
    if (timeInMinutes < 60) {
      return '$timeInMinutes دقيقة';
    } else {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
      } else {
        return '$hours ${hours == 1 ? 'ساعة' : 'ساعات'} و $minutes دقيقة';
      }
    }
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Open Google Maps with directions and polyline between two locations
  /// 
  /// [userLat] - User's current latitude
  /// [userLong] - User's current longitude
  /// [restaurantLat] - Restaurant's latitude
  /// [restaurantLong] - Restaurant's longitude
  static Future<bool> openGoogleMapsWithDirections({
    required double userLat,
    required double userLong,
    required double restaurantLat,
    required double restaurantLong,
  }) async {
    // Create Google Maps URL with directions
    // Using the directions API format: origin and destination
    final String googleMapsUrl = 
        'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLong&destination=$restaurantLat,$restaurantLong&travelmode=driving';
    
    final Uri uri = Uri.parse(googleMapsUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
