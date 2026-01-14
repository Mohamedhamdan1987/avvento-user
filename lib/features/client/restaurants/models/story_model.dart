class StoryRestaurant {
  final String id;
  final String name;
  final String logo;

  StoryRestaurant({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory StoryRestaurant.fromJson(Map<String, dynamic> json) {
    return StoryRestaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo,
    };
  }
}

class Story {
  final String id;
  final StoryRestaurant restaurant;
  final String mediaType;
  final String mediaUrl;
  final String? text;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewersCount;
  final int lovesCount;

  Story({
    required this.id,
    required this.restaurant,
    required this.mediaType,
    required this.mediaUrl,
    required this.text,
    required this.createdAt,
    required this.expiresAt,
    required this.viewersCount,
    required this.lovesCount,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'] as String,
      restaurant: StoryRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      mediaType: json['mediaType'] as String,
      mediaUrl: json['mediaUrl'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewersCount: json['viewersCount'] as int? ?? 0,
      lovesCount: json['lovesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurant': restaurant.toJson(),
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewersCount': viewersCount,
      'lovesCount': lovesCount,
    };
  }
}
