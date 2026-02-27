import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/home_service_item.dart';
import '../models/weekly_offer_model.dart';

class HomeSettingsResponse {
  final String appLogo;
  final List<HomeServiceItem> services;

  const HomeSettingsResponse({
    required this.appLogo,
    required this.services,
  });
}

class HomeRestaurantSectionItem {
  final String id;
  final String name;
  final String? backgroundImage;
  final String? logo;
  final bool isOpen;

  const HomeRestaurantSectionItem({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.logo,
    required this.isOpen,
  });

  factory HomeRestaurantSectionItem.fromJson(Map<String, dynamic> json) {
    return HomeRestaurantSectionItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      backgroundImage: json['backgroundImage']?.toString(),
      logo: json['logo']?.toString(),
      isOpen: json['isOpen'] as bool? ?? false,
    );
  }
}

class HomeMarketSectionItem {
  final String id;
  final String name;
  final String? backgroundImage;
  final String? logo;
  final bool isOpen;

  const HomeMarketSectionItem({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.logo,
    required this.isOpen,
  });

  factory HomeMarketSectionItem.fromJson(Map<String, dynamic> json) {
    return HomeMarketSectionItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      backgroundImage: json['backgroundImage']?.toString(),
      logo: json['logo']?.toString(),
      isOpen: json['isOpen'] as bool? ?? true,
    );
  }
}

class HomeSectionsResponse {
  final bool restaurantsEnabled;
  final List<HomeRestaurantSectionItem> restaurants;
  final bool marketsEnabled;
  final List<HomeMarketSectionItem> markets;
  final bool advertisementsEnabled;
  final List<HomeAdvertisementSectionItem> advertisements;

  const HomeSectionsResponse({
    required this.restaurantsEnabled,
    required this.restaurants,
    required this.marketsEnabled,
    required this.markets,
    required this.advertisementsEnabled,
    required this.advertisements,
  });
}

class HomeAdvertisementSectionItem {
  final String id;
  final String image;
  final int order;

  const HomeAdvertisementSectionItem({
    required this.id,
    required this.image,
    required this.order,
  });

  factory HomeAdvertisementSectionItem.fromJson(Map<String, dynamic> json) {
    return HomeAdvertisementSectionItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomeService {
  final DioClient _dioClient = DioClient.instance;

  Future<HomeSettingsResponse> getHomeServices() async {
    try {
      final response = await _dioClient.get('/app-settings');
      final data = response.data;

      if (data is Map<String, dynamic> && data['services'] is List) {
        final services = (data['services'] as List)
            .whereType<Map<String, dynamic>>()
            .map(HomeServiceItem.fromJson)
            .toList();
        final appLogo = (data['appLogo'] ?? '').toString();

        return HomeSettingsResponse(
          appLogo: appLogo,
          services: services,
        );
      }

      return const HomeSettingsResponse(
        appLogo: '',
        services: <HomeServiceItem>[],
      );
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

  Future<HomeSectionsResponse> getHomeSections() async {
    try {
      final response = await _dioClient.get('/app-settings/home-sections');
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        return const HomeSectionsResponse(
          restaurantsEnabled: false,
          restaurants: <HomeRestaurantSectionItem>[],
          marketsEnabled: false,
          markets: <HomeMarketSectionItem>[],
          advertisementsEnabled: false,
          advertisements: <HomeAdvertisementSectionItem>[],
        );
      }

      final restaurantsData = data['restaurants'] as Map<String, dynamic>?;
      final marketsData = data['markets'] as Map<String, dynamic>?;
      final advertisementsData = data['advertisements'] as Map<String, dynamic>?;

      final restaurantsEnabled = restaurantsData?['enabled'] as bool? ?? false;
      final marketsEnabled = marketsData?['enabled'] as bool? ?? false;
      final advertisementsEnabled = advertisementsData?['enabled'] as bool? ?? false;

      final restaurantsItemsRaw = restaurantsData?['items'] as List<dynamic>? ?? const [];
      final marketsItemsRaw = marketsData?['items'] as List<dynamic>? ?? const [];
      final advertisementsItemsRaw = advertisementsData?['items'] as List<dynamic>? ?? const [];

      final restaurants = restaurantsItemsRaw
          .whereType<Map<String, dynamic>>()
          .map(HomeRestaurantSectionItem.fromJson)
          .toList();

      final markets = marketsItemsRaw
          .whereType<Map<String, dynamic>>()
          .map(HomeMarketSectionItem.fromJson)
          .toList();

      final advertisements = advertisementsItemsRaw
          .whereType<Map<String, dynamic>>()
          .map(HomeAdvertisementSectionItem.fromJson)
          .toList();

      return HomeSectionsResponse(
        restaurantsEnabled: restaurantsEnabled,
        restaurants: restaurants,
        marketsEnabled: marketsEnabled,
        markets: markets,
        advertisementsEnabled: advertisementsEnabled,
        advertisements: advertisements,
      );
    } on DioException {
      rethrow;
    }
  }
}

