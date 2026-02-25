import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/home_service_item.dart';
import '../models/weekly_offer_model.dart';

class HomeService {
  final DioClient _dioClient = DioClient.instance;

  Future<List<HomeServiceItem>> getHomeServices() async {
    try {
      final response = await _dioClient.get('/app-settings');
      final data = response.data;

      if (data is Map<String, dynamic> && data['services'] is List) {
        return (data['services'] as List)
            .whereType<Map<String, dynamic>>()
            .map(HomeServiceItem.fromJson)
            .toList();
      }

      return <HomeServiceItem>[];
    } on DioException {
      rethrow;
    }
  }

  Future<List<WeeklyOffer>> getActiveWeeklyOffers() async {
    try {
      final response = await _dioClient.get('/weekly-offers/active');
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(WeeklyOffer.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(WeeklyOffer.fromJson)
            .toList();
      }

      return <WeeklyOffer>[];
    } on DioException {
      rethrow;
    }
  }
}

