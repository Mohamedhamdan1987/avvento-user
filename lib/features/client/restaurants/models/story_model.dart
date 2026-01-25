class StoryRestaurant {
  final String id;
  final String name;
  final String logo;
  final String? phone;

  StoryRestaurant({
    required this.id,
    required this.name,
    required this.logo,
    this.phone,
  });

  factory StoryRestaurant.fromJson(Map<String, dynamic> json) {
    return StoryRestaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo,
      if (phone != null) 'phone': phone,
    };
  }
}

class Story {
  final String id;
  final StoryRestaurant? restaurant;
  final String mediaType;
  final String mediaUrl;
  final String? text;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewersCount;
  final int lovesCount;

  Story({
    required this.id,
    this.restaurant,
    required this.mediaType,
    required this.mediaUrl,
    this.text,
    required this.createdAt,
    required this.expiresAt,
    required this.viewersCount,
    required this.lovesCount,
  });

  factory Story.fromJson(Map<String, dynamic> json, {StoryRestaurant? restaurant}) {
    return Story(
      id: json['_id'] as String,
      restaurant: restaurant ?? (json['restaurant'] != null ? StoryRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>) : null),
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
      if (restaurant != null) 'restaurant': restaurant!.toJson(),
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

class RestaurantStoryGroup {
  final StoryRestaurant restaurant;
  final int activeStoriesCount;
  final List<Story> stories;

  RestaurantStoryGroup({
    required this.restaurant,
    required this.activeStoriesCount,
    required this.stories,
  });

  factory RestaurantStoryGroup.fromJson(Map<String, dynamic> json) {
    final restaurant = StoryRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>);
    return RestaurantStoryGroup(
      restaurant: restaurant,
      activeStoriesCount: json['activeStoriesCount'] as int? ?? 0,
      stories: (json['stories'] as List<dynamic>?)
              ?.map((s) => Story.fromJson(s as Map<String, dynamic>, restaurant: restaurant))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant.toJson(),
      'activeStoriesCount': activeStoriesCount,
      'stories': stories.map((s) => s.toJson()).toList(),
    };
  }
}
