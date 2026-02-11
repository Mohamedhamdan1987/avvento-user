class StoryRestaurant {
  final String id;
  final String name;
  final String logo;
  final String? restaurantId;
  final String? description;
  final String? address;
  final String? phone;
  final bool isFav;
  final bool isFavorite;

  StoryRestaurant({
    required this.id,
    required this.name,
    required this.logo,
    this.restaurantId,
    this.description,
    this.address,
    this.phone,
    this.isFav = false,
    this.isFavorite = false,
  });

  factory StoryRestaurant.fromJson(Map<String, dynamic> json) {
    return StoryRestaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String? ?? '',
      restaurantId: json['restaurantId'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isFav: json['isFav'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      'isFav': isFav,
      'isFavorite': isFavorite,
    };
  }
}

class Story {
  final String id;
  final StoryRestaurant? restaurant;
  final String mediaType;
  final String? mediaUrl;
  final String? text;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewersCount;
  final int lovesCount;
  final int repliesCount;
  final bool isViewed;
  final bool isLoved;

  Story({
    required this.id,
    this.restaurant,
    required this.mediaType,
    this.mediaUrl,
    this.text,
    required this.createdAt,
    required this.expiresAt,
    required this.viewersCount,
    required this.lovesCount,
    required this.repliesCount,
    required this.isViewed,
    required this.isLoved,
  });

  factory Story.fromJson(Map<String, dynamic> json, {StoryRestaurant? restaurant}) {
    return Story(
      id: json['_id'] as String,
      restaurant: restaurant ?? (json['restaurant'] != null ? StoryRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>) : null),
      mediaType: json['mediaType'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      text: json['text'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewersCount: json['viewersCount'] as int? ?? 0,
      lovesCount: json['lovesCount'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      isViewed: json['isViewed'] as bool? ?? false,
      isLoved: json['isLoved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (restaurant != null) 'restaurant': restaurant!.toJson(),
      'mediaType': mediaType,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewersCount': viewersCount,
      'lovesCount': lovesCount,
      'repliesCount': repliesCount,
      'isViewed': isViewed,
      'isLoved': isLoved,
    };
  }
}

class RestaurantStoryGroup {
  final StoryRestaurant restaurant;
  final int activeStoriesCount;
  final List<Story> stories;

  /// Returns true if all stories in this group have been viewed
  bool get allViewed => stories.isNotEmpty && stories.every((s) => s.isViewed);

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
