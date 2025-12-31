import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/restaurant_model.dart';
import '../models/story_model.dart';

class RestaurantsService {
  final DioClient _dioClient = DioClient();

  /// Fetch restaurants with pagination and search
  /// 
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// - [limit]: Number of items per page (default: 10)
  /// - [search]: Search query string (optional)
  Future<RestaurantsResponse> getRestaurants({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Add search parameter if provided
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _dioClient.get(
        '/restaurants',
        queryParameters: queryParameters,
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      return RestaurantsResponse.fromJson(responseData);
    } on DioException {
      rethrow;
    }
  }

  /// Fetch restaurant stories
  Future<List<Story>> getStories() async {
    try {
      final response = await _dioClient.get('/stories');
      
      final responseData = response.data as List<dynamic>;
      return responseData.map((item) => Story.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }
}
