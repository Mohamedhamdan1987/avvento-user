/// Category item from GET /categories/selection (for filter chips).
class CategorySelection {
  final String id;
  final String name;
  final String? image;
  final String? icon;
  final String? color;

  CategorySelection({
    required this.id,
    required this.name,
    this.image,
    this.icon,
    this.color,
  });

  factory CategorySelection.fromJson(Map<String, dynamic> json) {
    return CategorySelection(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      icon: json['icon']?.toString(),
      color: json['color'] as String?,
    );
  }
}
