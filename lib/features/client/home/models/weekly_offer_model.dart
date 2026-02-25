import '../../restaurants/models/restaurant_model.dart';

class WeeklyOffer {
  final String id;
  final Restaurant restaurant;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int order;
  final String title;
  final String description;

  WeeklyOffer({
    required this.id,
    required this.restaurant,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.order,
    required this.title,
    required this.description,
  });

  factory WeeklyOffer.fromJson(Map<String, dynamic> json) {
    return WeeklyOffer(
      id: json['_id'] as String? ?? '',
      restaurant: Restaurant.fromJson(
        (json['restaurant'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
