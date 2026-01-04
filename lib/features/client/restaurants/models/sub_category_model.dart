class SubCategory {
  final String id;
  final String name;
  final String? image;
  final int order;
  final bool isActive;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.name,
    this.image,
    required this.order,
    required this.isActive,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      category: json['category'] as String,
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
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
