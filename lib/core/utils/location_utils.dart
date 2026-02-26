import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Utility class for location-based calculations
class LocationUtils {
  /// Price per kilometer for delivery (in Dirhams)
  static const double pricePerKm = 5.0;

  /// Current device location (updated via [init])
  static double? _currentLatitude;
  static double? _currentLongitude;
  static bool _initialized = false;

  /// Getters for current device location
  static double? get currentLatitude => _currentLatitude;
  static double? get currentLongitude => _currentLongitude;
  static bool get isInitialized => _initialized;

  /// Check if location permission is granted
  static Future<bool> hasPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Ensure location permission is granted and location is initialized
  /// This should be called when the app starts or when location is needed
  /// Returns true if permission is granted and location is available
  static Future<bool> ensureLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LocationUtils: Location services are disabled.');
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // If permission is denied, request it explicitly
      if (permission == LocationPermission.denied) {
        print('LocationUtils: Requesting location permission...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          print('LocationUtils: Location permission denied by user.');
          return false;
        }
      }

      // If permission is denied forever, inform user
      if (permission == LocationPermission.deniedForever) {
        print('LocationUtils: Location permission permanently denied.');
        return false;
      }

      // Check if we have permission (whileInUse or always)
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('LocationUtils: Location permission not granted.');
        return false;
      }

      // If we already have location, return true
      if (_initialized &&
          _currentLatitude != null &&
          _currentLongitude != null) {
        return true;
      }

      // Get current position
      print('LocationUtils: Fetching current location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;
      _initialized = true;
      print(
        'LocationUtils: Location initialized successfully ($_currentLatitude, $_currentLongitude)',
      );
      return true;
    } catch (e) {
      print('LocationUtils: Error getting location: $e');
      // Try to get last known position as fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _currentLatitude = lastPosition.latitude;
          _currentLongitude = lastPosition.longitude;
          _initialized = true;
          print(
            'LocationUtils: Using last known position ($_currentLatitude, $_currentLongitude)',
          );
          return true;
        }
      } catch (e2) {
        print('LocationUtils: Could not get last known position: $e2');
      }
      return false;
    }
  }

  /// Initialize location — requests permission and fetches current position.
  /// Should be called once at app startup (e.g. in main or a splash screen).
  /// This is a non-blocking initialization that doesn't force permission request.
  static Future<void> init() async {
    await ensureLocationPermission();
  }

  /// Request location permission explicitly
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('LocationUtils: Error requesting permission: $e');
      return false;
    }
  }

  /// Refresh the current location (can be called anytime to update)
  static Future<void> refreshLocation() async {
    // Ensure we have permission before refreshing
    if (!_initialized) {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('LocationUtils: Cannot refresh location without permission.');
        return;
      }
    }
    await init();
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  ///
  /// [userLat] - User's latitude (optional, defaults to current device location)
  /// [userLong] - User's longitude (optional, defaults to current device location)
  /// [restaurantLat] - Restaurant's latitude
  /// [restaurantLong] - Restaurant's longitude
  ///
  /// Throws [StateError] if location is not initialized and userLat/userLong are not provided
  static double calculateDistance({
    double? userLat,
    double? userLong,
    required double restaurantLat,
    required double restaurantLong,
  }) {
    // Use current device location if not provided
    final double actualUserLat =
        userLat ??
        _currentLatitude ??
        (throw StateError(
          'Location not initialized. Call LocationUtils.init() first or provide userLat/userLong.',
        ));
    final double actualUserLong =
        userLong ??
        _currentLongitude ??
        (throw StateError(
          'Location not initialized. Call LocationUtils.init() first or provide userLat/userLong.',
        ));

    // Earth's radius in kilometers
    const double earthRadiusKm = 6371.0;

    // Convert degrees to radians
    double lat1Rad = _degreesToRadians(actualUserLat);
    double lat2Rad = _degreesToRadians(restaurantLat);
    double deltaLatRad = _degreesToRadians(restaurantLat - actualUserLat);
    double deltaLongRad = _degreesToRadians(restaurantLong - actualUserLong);

    // Haversine formula
    double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLongRad / 2) *
            sin(deltaLongRad / 2);

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

}
