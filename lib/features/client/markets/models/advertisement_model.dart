class AdvertisementMarket {
  final String id;
  final String name;
  final String address;
  final String? logo;

  AdvertisementMarket({
    required this.id,
    required this.name,
    required this.address,
    this.logo,
  });

  factory AdvertisementMarket.fromJson(Map<String, dynamic> json) {
    return AdvertisementMarket(
      id: json['_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'logo': logo,
    };
  }
}

class Advertisement {
  final String id;
  final String title;
  final String description;
  final String image;
  final AdvertisementMarket? market;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.market,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String,
      market: json['market'] != null
          ? AdvertisementMarket.fromJson(json['market'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      priority: json['priority'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': image,
      'market': market?.toJson(),
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'priority': priority,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
