import '../../restaurants/models/menu_item_model.dart';

class CartItem {
  final String id;
  final MenuItem item;
  final int quantity;
  final List<String> selectedVariations;
  final List<String> selectedAddOns;
  final String notes;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.item,
    required this.quantity,
    required this.selectedVariations,
    required this.selectedAddOns,
    required this.notes,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'] as String,
      item: MenuItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedVariations: List<String>.from(json['selectedVariations'] ?? []),
      selectedAddOns: List<String>.from(json['selectedAddOns'] ?? []),
      notes: json['notes'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}

class CartRestaurant {
  final String id;
  final String name;
  final String? logo;
  final double? lat;
  final double? long;
  final String? username;
  final String? email;
  final String? phone;
  final String? restaurantId;

  CartRestaurant({
    required this.id,
    required this.name,
    this.logo,
    this.lat,
    this.long,
    this.username,
    this.email,
    this.phone,
    this.restaurantId,
  });

  factory CartRestaurant.fromJson(Map<String, dynamic> json) {
    // Try to find lat/long at top level
    double? lat = json['lat'] != null ? (json['lat'] as num).toDouble() : null;
    double? long = json['long'] != null ? (json['long'] as num).toDouble() : null;


    // // Fallback to alternative names if still not found
    // lat ??= json['latitude'] != null ? (json['latitude'] as num).toDouble() : null;
    // long ??= json['longitude'] != null ? (json['longitude'] as num).toDouble() : null;

    return CartRestaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      lat: lat,
      long: long,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      restaurantId: json['restaurantId'] as String?,
    );
  }
}

class RestaurantCartResponse {
  final String id;
  final String user;
  final CartRestaurant restaurant;
  final List<CartItem> items;
  final double totalPrice;

  RestaurantCartResponse({
    required this.id,
    required this.user,
    required this.restaurant,
    required this.items,
    required this.totalPrice,
  });

  factory RestaurantCartResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantCartResponse(
      id: json['_id'] as String,
      user: json['user'] as String,
      restaurant:
          CartRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
              ?.where((i) =>
                  i != null &&
                  i is Map<String, dynamic> &&
                  i['item'] is Map<String, dynamic>)
              .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}
