import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';

/// Utility class for polyline operations
class PolylineUtils {
  /// Decode polyline string to list of LatLng points
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  /// Get route polyline from Google Directions API
  /// Returns list of LatLng points following the actual road
  static Future<List<LatLng>> getRoutePolyline({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? apiKey,
  }) async {
    try {
      // Use test API key if not provided (you should replace this with your actual API key)
      final key = apiKey ?? 'AIzaSyAd3CV1YaNTaPm7tXZ_d71ps8TPdr-jyeI';

      final dio = Dio();
      final url = 'https://maps.googleapis.com/maps/api/directions/json';

      final queryParams = {
        'origin': '$originLat,$originLng',
        'destination': '$destLat,$destLng',
        'key': key,
        'language': 'ar',
      };

      print('🔵 [PolylineUtils] Calling Google Directions API...');
      print('🔵 [PolylineUtils] URL: $url');
      print('🔵 [PolylineUtils] Origin: $originLat,$originLng');
      print('🔵 [PolylineUtils] Destination: $destLat,$destLng');
      print('🔵 [PolylineUtils] API Key: ${key.substring(0, 10)}...');

      final response = await dio.get(url, queryParameters: queryParams);

      print('🟢 [PolylineUtils] Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('🟢 [PolylineUtils] Response Status: ${data['status']}');

        if (data['status'] == 'OK') {
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final route = data['routes'][0];

            if (route['overview_polyline'] != null &&
                route['overview_polyline']['points'] != null) {
              final polyline = route['overview_polyline']['points'];
              print(
                '🟢 [PolylineUtils] Polyline encoded string length: ${polyline.length}',
              );

              final decodedPoints = decodePolyline(polyline);
              print(
                '🟢 [PolylineUtils] Decoded points count: ${decodedPoints.length}',
              );

              if (decodedPoints.isNotEmpty) {
                print(
                  '✅ [PolylineUtils] Successfully got route with ${decodedPoints.length} points',
                );
                return decodedPoints;
              } else {
                print(
                  '⚠️ [PolylineUtils] Decoded points is empty, using fallback',
                );
              }
            } else {
              print('⚠️ [PolylineUtils] overview_polyline or points is null');
            }
          } else {
            print('⚠️ [PolylineUtils] Routes array is empty');
          }
        } else {
          print(
            '❌ [PolylineUtils] API returned error status: ${data['status']}',
          );
          if (data['error_message'] != null) {
            print('❌ [PolylineUtils] Error message: ${data['error_message']}');
          }
        }
      } else {
        print(
          '❌ [PolylineUtils] HTTP Error: Status code ${response.statusCode}',
        );
      }

      // If API fails, return straight line as fallback
      print('⚠️ [PolylineUtils] Using fallback: straight line');
      return [LatLng(originLat, originLng), LatLng(destLat, destLng)];
    } catch (e, stackTrace) {
      // If API fails, return straight line as fallback
      print('❌ [PolylineUtils] Exception occurred: $e');
      print('❌ [PolylineUtils] Stack trace: $stackTrace');
      print('⚠️ [PolylineUtils] Using fallback: straight line');
      return [LatLng(originLat, originLng), LatLng(destLat, destLng)];
    }
  }
}
