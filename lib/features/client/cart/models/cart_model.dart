import '../../restaurants/models/menu_item_model.dart';

class CartDeliveryFeeEstimate {
  final double deliveryFee;
  final double finalPrice;
  final double distance;
  final double dayPrice;
  final double nightPrice;
  final bool isNight;

  CartDeliveryFeeEstimate({
    required this.deliveryFee,
    required this.finalPrice,
    required this.distance,
    required this.dayPrice,
    required this.nightPrice,
    required this.isNight,
  });

  factory CartDeliveryFeeEstimate.fromJson(Map<String, dynamic> json) {
    return CartDeliveryFeeEstimate(
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      dayPrice: (json['dayPrice'] as num?)?.toDouble() ?? 0,
      nightPrice: (json['nightPrice'] as num?)?.toDouble() ?? 0,
      isNight: json['isNight'] as bool? ?? false,
    );
  }
}

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
  final CartDeliveryFeeEstimate? deliveryFeeEstimate;
  final double deliveryFee;
  final double tax;
  final double totalPriceWithShipping;

  RestaurantCartResponse({
    required this.id,
    required this.user,
    required this.restaurant,
    required this.items,
    required this.totalPrice,
    this.deliveryFeeEstimate,
    this.deliveryFee = 0,
    this.tax = 0,
    this.totalPriceWithShipping = 0,
  });

  factory RestaurantCartResponse.fromJson(Map<String, dynamic> json) {
    final restaurantJson = json['restaurant'];
    if (restaurantJson == null || restaurantJson is! Map<String, dynamic>) {
      throw FormatException(
          'Invalid cart response: restaurant field is null or not a map');
    }
    return RestaurantCartResponse(
      id: json['_id'] as String,
      user: json['user'] as String,
      restaurant: CartRestaurant.fromJson(restaurantJson),
      items: (json['items'] as List<dynamic>?)
              ?.where((i) =>
                  i != null &&
                  i is Map<String, dynamic> &&
                  i['item'] is Map<String, dynamic>)
              .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      deliveryFeeEstimate: json['deliveryFeeEstimate'] is Map<String, dynamic>
          ? CartDeliveryFeeEstimate.fromJson(
              json['deliveryFeeEstimate'] as Map<String, dynamic>,
            )
          : null,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      totalPriceWithShipping:
          (json['totalPriceWithShipping'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
