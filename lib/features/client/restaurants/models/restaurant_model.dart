class DeliveryFeeEstimate {
  final double deliveryFee;
  final double finalPrice;
  final double distance;
  final double dayPrice;
  final double nightPrice;
  final bool isNight;

  DeliveryFeeEstimate({
    required this.deliveryFee,
    required this.finalPrice,
    required this.distance,
    required this.dayPrice,
    required this.nightPrice,
    required this.isNight,
  });

  factory DeliveryFeeEstimate.fromJson(Map<String, dynamic> json) {
    return DeliveryFeeEstimate(
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      dayPrice: (json['dayPrice'] as num?)?.toDouble() ?? 0,
      nightPrice: (json['nightPrice'] as num?)?.toDouble() ?? 0,
      isNight: json['isNight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryFee': deliveryFee,
      'finalPrice': finalPrice,
      'distance': distance,
      'dayPrice': dayPrice,
      'nightPrice': nightPrice,
      'isNight': isNight,
    };
  }

  String get displayFee => '${finalPrice.toStringAsFixed(1)} دينار';
  String get displayDistance => distance < 1
      ? '${(distance * 1000).toStringAsFixed(0)} م'
      : '${distance.toStringAsFixed(1)} كم';
}

class RestaurantUser {
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
  final String workingStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantUser({
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
    this.workingStatus = 'stopped',
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantUser.fromJson(Map<String, dynamic> json) {
    // Handle both 'user' object and 'host' object formats
    final String id = json['_id'] ?? json['id'] ?? json['hostId'] ?? '';
    final String name = json['name'] ?? json['hostName'] ?? '';
    final String username = json['username'] ?? json['hostUsername'] ?? '';
    final String email = json['email'] ?? json['hostEmail'] ?? '';
    final String phone = json['phone'] ?? json['hostPhone'] ?? '';
    final String role = json['role'] ?? json['hostRole'] ?? '';
    final bool isVerified = json['isVerified'] ?? json['hostVerified'] ?? false;
    final bool isActive = json['isActive'] ?? json['hostActive'] ?? false;
    final String address = json['address'] ?? json['hostAddress'] ?? '';
    
    double lat = 0.0;
    double long = 0.0;
    
    if (json['lat'] != null) lat = (json['lat'] as num).toDouble();
    if (json['long'] != null) long = (json['long'] as num).toDouble();
    
    // Check if location is nested (common in 'host' object)
    if (json['hostLocation'] != null) {
      final loc = json['hostLocation'] as Map<String, dynamic>;
      if (loc['lat'] != null) lat = (loc['lat'] as num).toDouble();
      if (loc['long'] != null) long = (loc['long'] as num).toDouble();
    } else if (json['location'] != null) {
      final loc = json['location'] as Map<String, dynamic>;
      if (loc['lat'] != null) lat = (loc['lat'] as num).toDouble();
      if (loc['long'] != null) long = (loc['long'] as num).toDouble();
    }

    return RestaurantUser(
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
      workingStatus: json['workingStatus'] ?? 'stopped',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
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

/// Rating info from API (statistics.rating or top-level).
class RestaurantRating {
  final double average;
  final int totalRatings;

  RestaurantRating({required this.average, required this.totalRatings});

  factory RestaurantRating.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantRating(average: 0, totalRatings: 0);
    return RestaurantRating(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      totalRatings: (json['totalRatings'] as int?) ?? 0,
    );
  }

  /// Display string e.g. "4.00"
  String get display => average.toStringAsFixed(2);
}

/// Statistics from API (statistics object).
class RestaurantStatistics {
  final RestaurantRating rating;
  final int averagePreparationTime;

  RestaurantStatistics({
    required this.rating,
    required this.averagePreparationTime,
  });

  factory RestaurantStatistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RestaurantStatistics(
        rating: RestaurantRating(average: 0, totalRatings: 0),
        averagePreparationTime: 0,
      );
    }
    final ratingJson = json['rating'] as Map<String, dynamic>?;
    return RestaurantStatistics(
      rating: RestaurantRating.fromJson(ratingJson),
      averagePreparationTime: (json['averagePreparationTime'] as int?) ?? 0,
    );
  }
}

class Restaurant {
  final String id;
  final RestaurantUser user;
  final String name;
  final String address;
  final double lat;
  final double long;
  final String? backgroundImage;
  final String? logo;
  final String ownerName;
  final String description;
  final String phone;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isOpen;
  final double earnings;
  final double withdrawnAmount;
  final double availableBalance;
  final double commissionPercentage;
  final DeliveryFeeEstimate? deliveryFeeEstimate;
  final RestaurantStatistics? statistics;
  final String? averageRatingString;
  final int? totalRatingsTopLevel;

  Restaurant({
    required this.id,
    required this.user,
    required this.name,
    required this.address,
    required this.lat,
    required this.long,
    this.backgroundImage,
    this.logo,
    required this.ownerName,
    required this.description,
    required this.phone,
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isOpen = false,
    this.earnings = 0,
    this.withdrawnAmount = 0,
    this.availableBalance = 0,
    this.commissionPercentage = 0,
    this.deliveryFeeEstimate,
    this.statistics,
    this.averageRatingString,
    this.totalRatingsTopLevel,
  });

  /// Average rating for display (from statistics or top-level).
  String get averageRatingDisplay {
    if (statistics != null && statistics!.rating.totalRatings > 0) {
      return statistics!.rating.display;
    }
    if (averageRatingString != null && averageRatingString!.isNotEmpty) {
      return averageRatingString!;
    }
    return '0.00';
  }

  /// Preparation time in minutes (from statistics).
  int get averagePreparationTimeMinutes =>
      statistics?.averagePreparationTime ?? 0;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Handle both 'user' and 'host' keys
    Map<String, dynamic>? userData = json['user'] as Map<String, dynamic>?;
    if (userData == null && json['host'] != null) {
      userData = json['host'] as Map<String, dynamic>;
    }
    
    // Fallback to top-level fields if nested user/host is missing but some fields are present
    if (userData == null) {
      userData = json; 
    }

    double lat = 0.0;
    double long = 0.0;
    
    if (json['lat'] != null) lat = (json['lat'] as num).toDouble();
    if (json['long'] != null) long = (json['long'] as num).toDouble();
    
    // Check if location is nested
    if (json['location'] != null) {
       final loc = json['location'] as Map<String, dynamic>;
       if (loc['lat'] != null) lat = (loc['lat'] as num).toDouble();
       if (loc['long'] != null) long = (loc['long'] as num).toDouble();
    }

    final statisticsJson = json['statistics'] as Map<String, dynamic>?;
    final RestaurantStatistics? statistics = statisticsJson != null
        ? RestaurantStatistics.fromJson(statisticsJson)
        : null;
    final String? averageRatingString = json['averageRating']?.toString();
    final int? totalRatingsTopLevel = json['totalRatings'] as int?;

    final deliveryFeeJson = json['deliveryFeeEstimate'] as Map<String, dynamic>?;
    final DeliveryFeeEstimate? deliveryFeeEstimate = deliveryFeeJson != null
        ? DeliveryFeeEstimate.fromJson(deliveryFeeJson)
        : null;

    final categoriesRaw = json['categories'] as List<dynamic>?;
    final List<String> categories = categoriesRaw != null
        ? categoriesRaw.map((e) => e.toString()).toList()
        : [];

    return Restaurant(
      id: json['_id'] ?? json['id'] ?? '',
      user: RestaurantUser.fromJson(userData),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: lat,
      long: long,
      backgroundImage: json['backgroundImage'] as String?,
      logo: json['logo'] as String?,
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      categories: categories,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isOpen: json['isOpen'] as bool? ?? false,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
      withdrawnAmount: (json['withdrawnAmount'] as num?)?.toDouble() ?? 0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      commissionPercentage: (json['commissionPercentage'] as num?)?.toDouble() ?? 0,
      deliveryFeeEstimate: deliveryFeeEstimate,
      statistics: statistics,
      averageRatingString: averageRatingString,
      totalRatingsTopLevel: totalRatingsTopLevel,
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
      'backgroundImage': backgroundImage,
      'logo': logo,
      'ownerName': ownerName,
      'description': description,
      'phone': phone,
      'categories': categories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isOpen': isOpen,
      'earnings': earnings,
      'withdrawnAmount': withdrawnAmount,
      'availableBalance': availableBalance,
      'commissionPercentage': commissionPercentage,
      if (deliveryFeeEstimate != null) 'deliveryFeeEstimate': deliveryFeeEstimate!.toJson(),
      if (statistics != null) 'statistics': {
        'rating': {'average': statistics!.rating.average, 'totalRatings': statistics!.rating.totalRatings},
        'averagePreparationTime': statistics!.averagePreparationTime,
      },
      'averageRating': averageRatingDisplay,
      'totalRatings': totalRatingsTopLevel ?? statistics?.rating.totalRatings,
    };
  }

  Restaurant copyWith({
    String? id,
    RestaurantUser? user,
    String? name,
    String? address,
    double? lat,
    double? long,
    String? backgroundImage,
    String? logo,
    String? ownerName,
    String? description,
    String? phone,
    List<String>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isOpen,
    double? earnings,
    double? withdrawnAmount,
    double? availableBalance,
    double? commissionPercentage,
    DeliveryFeeEstimate? deliveryFeeEstimate,
    RestaurantStatistics? statistics,
    String? averageRatingString,
    int? totalRatingsTopLevel,
  }) {
    return Restaurant(
      id: id ?? this.id,
      user: user ?? this.user,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      logo: logo ?? this.logo,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isOpen: isOpen ?? this.isOpen,
      earnings: earnings ?? this.earnings,
      withdrawnAmount: withdrawnAmount ?? this.withdrawnAmount,
      availableBalance: availableBalance ?? this.availableBalance,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      deliveryFeeEstimate: deliveryFeeEstimate ?? this.deliveryFeeEstimate,
      statistics: statistics ?? this.statistics,
      averageRatingString: averageRatingString ?? this.averageRatingString,
      totalRatingsTopLevel: totalRatingsTopLevel ?? this.totalRatingsTopLevel,
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

class RestaurantsResponse {
  final List<Restaurant> data;
  final PaginationModel pagination;

  RestaurantsResponse({
    required this.data,
    required this.pagination,
  });

  factory RestaurantsResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantsResponse(
      data: ((json['data'] ?? json['restaurants']) as List<dynamic>)
          .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((restaurant) => restaurant.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
