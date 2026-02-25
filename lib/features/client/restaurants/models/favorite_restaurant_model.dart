import 'restaurant_model.dart';

class FavoriteRestaurant {
  final String id;
  final String userId;
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
  final DeliveryFeeEstimate? deliveryFeeEstimate;

  FavoriteRestaurant({
    required this.id,
    required this.userId,
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
    this.isFavorite = true,
    this.deliveryFeeEstimate,
  });

  factory FavoriteRestaurant.fromJson(Map<String, dynamic> json) {
    final deliveryFeeJson = json['deliveryFeeEstimate'] as Map<String, dynamic>?;

    return FavoriteRestaurant(
      id: json['_id'] as String,
      userId: json['user'] is String ? json['user'] as String : (json['user']?['_id'] ?? ''),
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
      isOpen: json['isOpen'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? true,
      deliveryFeeEstimate: deliveryFeeJson != null
          ? DeliveryFeeEstimate.fromJson(deliveryFeeJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
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
      if (deliveryFeeEstimate != null) 'deliveryFeeEstimate': deliveryFeeEstimate!.toJson(),
    };
  }
}
