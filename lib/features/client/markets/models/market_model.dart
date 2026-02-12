class MarketUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String address;
  final double lat;
  final double long;
  final String? backgroundImage;
  final String? logo;
  final String ownerName;
  final String description;
  final String deliveryStatus;
  final String? workingStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.address,
    required this.lat,
    required this.long,
    this.backgroundImage,
    this.logo,
    required this.ownerName,
    required this.description,
    required this.deliveryStatus,
    this.workingStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketUser.fromJson(Map<String, dynamic> json) {
    final String id = json['_id'] ?? json['id'] ?? '';
    final String name = json['name'] ?? '';
    final String username = json['username'] ?? '';
    final String email = json['email'] ?? '';
    final String phone = json['phone'] ?? '';
    final String role = json['role'] ?? '';
    final bool isVerified = json['isVerified'] ?? false;
    final bool isActive = json['isActive'] ?? false;
    final String address = json['address'] ?? '';

    double lat = 0.0;
    double long = 0.0;

    if (json['lat'] != null) lat = (json['lat'] as num).toDouble();
    if (json['long'] != null) long = (json['long'] as num).toDouble();

    if (json['location'] != null) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['lat'] != null) lat = (loc['lat'] as num).toDouble();
      if (loc['long'] != null) long = (loc['long'] as num).toDouble();
    }

    return MarketUser(
      id: id,
      name: name,
      username: username,
      email: email,
      phone: phone,
      role: role,
      isVerified: isVerified,
      isActive: isActive,
      address: address,
      lat: lat,
      long: long,
      backgroundImage: json['backgroundImage'] as String?,
      logo: json['logo'] as String?,
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      deliveryStatus: json['deliveryStatus'] ?? '',
      workingStatus: json['workingStatus'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'address': address,
      'lat': lat,
      'long': long,
      'backgroundImage': backgroundImage,
      'logo': logo,
      'ownerName': ownerName,
      'description': description,
      'deliveryStatus': deliveryStatus,
      'workingStatus': workingStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MarketRating {
  final double average;
  final int totalRatings;

  MarketRating({required this.average, required this.totalRatings});

  factory MarketRating.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketRating(average: 0, totalRatings: 0);
    return MarketRating(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      totalRatings: (json['totalRatings'] as int?) ?? 0,
    );
  }

  String get display => average.toStringAsFixed(1);
}

class MarketStatistics {
  final MarketRating rating;
  final int averageDeliveryTime;

  MarketStatistics({
    required this.rating,
    required this.averageDeliveryTime,
  });

  factory MarketStatistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MarketStatistics(
        rating: MarketRating(average: 0, totalRatings: 0),
        averageDeliveryTime: 0,
      );
    }
    final ratingJson = json['rating'] as Map<String, dynamic>?;
    return MarketStatistics(
      rating: MarketRating.fromJson(ratingJson),
      averageDeliveryTime: (json['averageDeliveryTime'] as int?) ?? 0,
    );
  }
}

class MarketProduct {
  final String id;
  final String name;
  final String? image;
  final double price;

  MarketProduct({
    required this.id,
    required this.name,
    this.image,
    required this.price,
  });

  factory MarketProduct.fromJson(Map<String, dynamic> json) {
    return MarketProduct(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'price': price,
    };
  }
}

class Market {
  final String id;
  final MarketUser user;
  final String name;
  final String address;
  final double lat;
  final double long;
  final String? logo;
  final String? backgroundImage;
  final String ownerName;
  final String description;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final MarketStatistics? statistics;
  final String? averageRatingString;
  final int? totalRatingsTopLevel;
  final double? deliveryFee;
  final int? deliveryTimeMinutes;
  final int? totalProducts;
  final List<MarketProduct>? featuredProducts;

  Market({
    required this.id,
    required this.user,
    required this.name,
    required this.address,
    required this.lat,
    required this.long,
    this.logo,
    this.backgroundImage,
    required this.ownerName,
    required this.description,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.statistics,
    this.averageRatingString,
    this.totalRatingsTopLevel,
    this.deliveryFee,
    this.deliveryTimeMinutes,
    this.totalProducts,
    this.featuredProducts,
  });

  /// Market is open if user.isActive && workingStatus != 'stopped'
  bool get isOpen {
    if (user.workingStatus == 'stopped') return false;
    return user.isActive;
  }

  String get averageRatingDisplay {
    if (statistics != null && statistics!.rating.totalRatings > 0) {
      return statistics!.rating.display;
    }
    if (averageRatingString != null && averageRatingString!.isNotEmpty) {
      return averageRatingString!;
    }
    return '0.0';
  }

  int get deliveryTime =>
      deliveryTimeMinutes ?? statistics?.averageDeliveryTime ?? 0;

  String get deliveryFeeDisplay {
    if (deliveryFee != null && deliveryFee! > 0) {
      return 'توصيل ${deliveryFee!.toStringAsFixed(0)} د.ل';
    }
    return 'توصيل مجاني';
  }

  bool get hasFreeDelivery => deliveryFee == null || deliveryFee == 0;

  factory Market.fromJson(Map<String, dynamic> json) {
    // Handle 'user' object
    Map<String, dynamic>? userData = json['user'] as Map<String, dynamic>?;
    userData ??= json;

    double lat = 0.0;
    double long = 0.0;

    if (json['lat'] != null) lat = (json['lat'] as num).toDouble();
    if (json['long'] != null) long = (json['long'] as num).toDouble();

    if (json['location'] != null) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['lat'] != null) lat = (loc['lat'] as num).toDouble();
      if (loc['long'] != null) long = (loc['long'] as num).toDouble();
    }

    final statisticsJson = json['statistics'] as Map<String, dynamic>?;
    final MarketStatistics? statistics = statisticsJson != null
        ? MarketStatistics.fromJson(statisticsJson)
        : null;

    List<MarketProduct>? featuredProducts;
    if (json['featuredProducts'] != null) {
      featuredProducts = (json['featuredProducts'] as List<dynamic>)
          .map((item) => MarketProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Market(
      id: json['_id'] ?? json['id'] ?? '',
      user: MarketUser.fromJson(userData),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: lat,
      long: long,
      logo: json['logo'] as String?,
      backgroundImage: json['backgroundImage'] as String?,
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      statistics: statistics,
      averageRatingString: json['averageRating']?.toString(),
      totalRatingsTopLevel: json['totalRatings'] as int?,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      deliveryTimeMinutes: json['deliveryTimeMinutes'] as int?,
      totalProducts: json['totalProducts'] as int?,
      featuredProducts: featuredProducts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'name': name,
      'address': address,
      'lat': lat,
      'long': long,
      'logo': logo,
      'backgroundImage': backgroundImage,
      'ownerName': ownerName,
      'description': description,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'deliveryFee': deliveryFee,
      'deliveryTimeMinutes': deliveryTimeMinutes,
      'totalProducts': totalProducts,
      if (featuredProducts != null)
        'featuredProducts':
            featuredProducts!.map((p) => p.toJson()).toList(),
    };
  }

  Market copyWith({
    String? id,
    MarketUser? user,
    String? name,
    String? address,
    double? lat,
    double? long,
    String? logo,
    String? backgroundImage,
    String? ownerName,
    String? description,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    MarketStatistics? statistics,
    String? averageRatingString,
    int? totalRatingsTopLevel,
    double? deliveryFee,
    int? deliveryTimeMinutes,
    int? totalProducts,
    List<MarketProduct>? featuredProducts,
  }) {
    return Market(
      id: id ?? this.id,
      user: user ?? this.user,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      logo: logo ?? this.logo,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      statistics: statistics ?? this.statistics,
      averageRatingString: averageRatingString ?? this.averageRatingString,
      totalRatingsTopLevel: totalRatingsTopLevel ?? this.totalRatingsTopLevel,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTimeMinutes: deliveryTimeMinutes ?? this.deliveryTimeMinutes,
      totalProducts: totalProducts ?? this.totalProducts,
      featuredProducts: featuredProducts ?? this.featuredProducts,
    );
  }
}

class MarketPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  MarketPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory MarketPagination.fromJson(Map<String, dynamic> json) {
    return MarketPagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class MarketsResponse {
  final List<Market> data;
  final MarketPagination? pagination;

  MarketsResponse({
    required this.data,
    this.pagination,
  });

  factory MarketsResponse.fromJson(Map<String, dynamic> json) {
    // Handle pagination — may or may not be present
    MarketPagination? pagination;
    if (json['pagination'] != null) {
      pagination = MarketPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
    }

    return MarketsResponse(
      data: ((json['data'] ?? json['markets'] ?? []) as List<dynamic>)
          .map((item) => Market.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }
}
