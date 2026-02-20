class Variation {
  final String id;
  final String name;
  final double price;

  Variation({required this.id, required this.name, required this.price});

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'price': price};
}

class AddOn {
  final String id;
  final String name;
  final double price;

  AddOn({required this.id, required this.name, required this.price});

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'price': price};
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String categoryId;
  final String categoryName;
  final bool isAvailable;
  final bool isFav;
  final int preparationTime;
  final num? calories;
  final String restaurant;
  final List<Variation> variations;
  final List<AddOn> addOns;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.categoryId,
    required this.categoryName,
    required this.isAvailable,
    required this.isFav,
    required this.preparationTime,
    this.calories,
    required this.restaurant,
    required this.variations,
    required this.addOns,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final category =
        json['category'] as Map<String, dynamic>? ?? {'_id': '', 'name': ''};
    return MenuItem(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
      categoryId: category['_id'] as String,
      categoryName: category['name'] as String,
      isAvailable: json['isAvailable'] as bool? ?? false,
      isFav: json['isFav'] as bool? ?? false,
      preparationTime: json['preparationTime'] as int? ?? 0,
      calories: json['calories'] as num? ?? 0,
      restaurant: json['restaurant'] is String
          ? json['restaurant'] as String
          : (json['restaurant'] as Map<String, dynamic>)['_id'] as String,
      variations: (json['variations'] as List<dynamic>? ?? [])
          .map((v) => Variation.fromJson(v as Map<String, dynamic>))
          .toList(),
      addOns: (json['addOns'] as List<dynamic>? ?? [])
          .map((a) => AddOn.fromJson(a as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': {'_id': categoryId, 'name': categoryName},
      'isAvailable': isAvailable,
      'isFav': isFav,
      'preparationTime': preparationTime,
      'calories': calories,
      'restaurant': restaurant,
      'variations': variations.map((v) => v.toJson()).toList(),
      'addOns': addOns.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? categoryId,
    String? categoryName,
    bool? isAvailable,
    bool? isFav,
    int? preparationTime,
    num? calories,
    String? restaurant,
    List<Variation>? variations,
    List<AddOn>? addOns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isAvailable: isAvailable ?? this.isAvailable,
      isFav: isFav ?? this.isFav,
      preparationTime: preparationTime ?? this.preparationTime,
      calories: calories ?? this.calories,
      restaurant: restaurant ?? this.restaurant,
      variations: variations ?? this.variations,
      addOns: addOns ?? this.addOns,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
