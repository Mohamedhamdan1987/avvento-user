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
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantUser.fromJson(Map<String, dynamic> json) {
    return RestaurantUser(
      id: json['_id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
      backgroundImage: json['backgroundImage'] as String?,
      logo: json['logo'] as String?,
      ownerName: json['ownerName'] as String,
      description: json['description'] as String,
      deliveryStatus: json['deliveryStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] as String,
      user: RestaurantUser.fromJson(json['user'] as Map<String, dynamic>),
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
      backgroundImage: json['backgroundImage'] as String?,
      logo: json['logo'] as String?,
      ownerName: json['ownerName'] as String,
      description: json['description'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
      data: (json['data'] as List<dynamic>)
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
