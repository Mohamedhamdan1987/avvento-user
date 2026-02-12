class MarketCategory {
  final String id;
  final String name;
  final String? icon;
  final String? image;

  MarketCategory({
    required this.id,
    required this.name,
    this.icon,
    this.image,
  });

  factory MarketCategory.fromJson(Map<String, dynamic> json) {
    return MarketCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] as String?,
      image: json['image'] as String?,
    );
  }
}
