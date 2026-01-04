class MenuCategory {
  final String id;
  final String name;
  final String? image;
  final int order;
  final bool isActive;
  final String restaurant;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuCategory({
    required this.id,
    required this.name,
    this.image,
    required this.order,
    required this.isActive,
    required this.restaurant,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      restaurant: json['restaurant'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'order': order,
      'isActive': isActive,
      'restaurant': restaurant,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
