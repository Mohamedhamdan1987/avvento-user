class BestRestaurantUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;

  BestRestaurantUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory BestRestaurantUser.fromJson(Map<String, dynamic> json) {
    return BestRestaurantUser(
      id: json['_id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
    };
  }
}

class Rating {
  final dynamic average; // Can be int or double
  final int totalRatings;

  Rating({
    required this.average,
    required this.totalRatings,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: json['average'],
      totalRatings: json['totalRatings'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'totalRatings': totalRatings,
    };
  }
}

class BestRestaurant {
  final String id;
  final BestRestaurantUser user;
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
  final bool isOpen;
  final bool isFavorite;
  final Rating rating;

  BestRestaurant({
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
    required this.isOpen,
    required this.isFavorite,
    required this.rating,
  });

  factory BestRestaurant.fromJson(Map<String, dynamic> json) {
    return BestRestaurant(
      id: json['_id'] as String,
      user: BestRestaurantUser.fromJson(json['user'] as Map<String, dynamic>),
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      long: (json['long'] as num?)?.toDouble() ?? 0.0,
      backgroundImage: json['backgroundImage'] as String?,
      logo: json['logo'] as String?,
      ownerName: json['ownerName'] as String,
      description: json['description'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isOpen: json['isOpen'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>),
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
      'isOpen': isOpen,
      'isFavorite': isFavorite,
      'rating': rating.toJson(),
    };
  }

  BestRestaurant copyWith({
    String? id,
    BestRestaurantUser? user,
    String? name,
    String? address,
    double? lat,
    double? long,
    String? backgroundImage,
    String? logo,
    String? ownerName,
    String? description,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOpen,
    bool? isFavorite,
    Rating? rating,
  }) {
    return BestRestaurant(
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
    );
  }
}
