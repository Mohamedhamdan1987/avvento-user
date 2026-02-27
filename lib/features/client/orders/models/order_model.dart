class OrderItem {
  final String itemId;
  final int quantity;
  final List<String> selectedVariations;
  final List<String> selectedAddOns;
  final String notes;
  final double unitPrice;
  final double totalPrice;
  final String id;
  final String name;
  final String? image;

  OrderItem({
    required this.itemId,
    required this.quantity,
    required this.selectedVariations,
    required this.selectedAddOns,
    required this.notes,
    required this.unitPrice,
    required this.totalPrice,
    required this.id,
    required this.name,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle item as Map (populated) or String (ID)
    // Also check for 'drink' key as fallback if 'item' is missing (for drinks added to order)
    // Also check for 'marketProduct' key for market orders
    dynamic itemData = json['item'] ?? json['drink'] ?? json['marketProduct'];
    
    String itemId = '';
    String name = 'Unknown Item';
    String? image;

    if (itemData is Map) {
      final map = itemData as Map<String, dynamic>;
      // For market products, the actual product info is nested under 'product'
      final productData = map['product'];
      if (productData is Map) {
        final productMap = productData as Map<String, dynamic>;
        itemId = productMap['_id'] as String? ?? map['_id'] as String? ?? '';
        name = (productMap['name'] as String?) ?? (productMap['nameAr'] as String?) ?? (productMap['nameEn'] as String?) ?? 'Unknown Item';
        final images = productMap['images'];
        if (images is List && images.isNotEmpty) {
          image = images.first as String?;
        } else {
          image = productMap['image'] as String?;
        }
      } else {
        itemId = map['_id'] as String? ?? '';
        name = (map['name'] as String?) ?? (map['nameAr'] as String?) ?? (map['nameEn'] as String?) ?? 'Unknown Item';
        image = map['image'] as String?;
      }
    } else if (itemData is String) {
      itemId = itemData;
    }
        
    return OrderItem(
      itemId: itemId,
      quantity: json['quantity'] as int? ?? 0,
      selectedVariations: List<String>.from(json['selectedVariations'] ?? []),
      selectedAddOns: List<String>.from(json['selectedAddOns'] ?? []),
      notes: json['notes'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      id: json['_id'] as String? ?? '',
      name: name,
      image: image,
    );
  }
}

class OrderRestaurant {
  final String id;
  final String name;
  final String? logo;

  OrderRestaurant({
    required this.id,
    required this.name,
    this.logo,
  });

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) {
    return OrderRestaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
    );
  }
}

class OrderDriver {
  final String id;
  final String name;
  final String? username;
  final String? phone;
  final String? image;

  OrderDriver({
    required this.id,
    required this.name,
    this.username,
    this.phone,
    this.image,
  });

  factory OrderDriver.fromJson(Map<String, dynamic> json) {
    return OrderDriver(
      id: json['_id'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
    );
  }
}

class RatingDetails {
  final int rating;
  final String comment;
  final DateTime? createdAt;

  RatingDetails({
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory RatingDetails.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    final parsedRating = rawRating is num
        ? rawRating.toInt()
        : int.tryParse(rawRating?.toString() ?? '') ?? 0;

    return RatingDetails(
      rating: parsedRating,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class OrderRating {
  final RatingDetails? restaurant;
  final RatingDetails? driver;

  OrderRating({
    this.restaurant,
    this.driver,
  });

  factory OrderRating.fromJson(Map<String, dynamic> json) {
    return OrderRating(
      restaurant: json['restaurant'] is Map<String, dynamic>
          ? RatingDetails.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] is Map<String, dynamic>
          ? RatingDetails.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final OrderRestaurant restaurant;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double totalPrice;
  final String status;
  final OrderDriver? driver;
  final OrderRating? orderRating;
  final String? deliveryAddress;  // Changed to nullable as it might be missing or object
  final double? deliveryLat;      // Changed to nullable
  final double? deliveryLong;     // Changed to nullable
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurant,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.totalPrice,
    required this.status,
    this.driver,
    this.orderRating,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLong,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle user as Map (populated) or String (ID)
    final userId = json['user'] is Map 
        ? (json['user'] as Map<String, dynamic>)['_id'] as String
        : json['user'] as String;

    // Handle both restaurant and market orders
    // Market orders have 'market' instead of 'restaurant'
    final restaurantData = json['restaurant'] ?? json['market'];
    final restaurant = restaurantData is Map
        ? OrderRestaurant.fromJson(restaurantData as Map<String, dynamic>)
        : OrderRestaurant(id: restaurantData as String? ?? '', name: 'Unknown');

    return OrderModel(
      id: json['_id'] as String,
      userId: userId,
      restaurant: restaurant,
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      driver: (json['delivery'] ?? json['driver']) != null 
          ? OrderDriver.fromJson((json['delivery'] ?? json['driver']) as Map<String, dynamic>) 
          : null,
      orderRating: json['orderRating'] is Map<String, dynamic>
          ? OrderRating.fromJson(json['orderRating'] as Map<String, dynamic>)
          : null,
      deliveryAddress: json['deliveryAddress'] is Map 
          ? (json['deliveryAddress'] as Map<String, dynamic>)['address'] as String?
          : json['deliveryAddress'] as String?,
      deliveryLat: json['deliveryLat'] != null ? (json['deliveryLat'] as num).toDouble() : null,
      deliveryLong: json['deliveryLong'] != null ? (json['deliveryLong'] as num).toDouble() : null,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class OrdersResponse {
  final List<OrderModel> orders;
  final int total;
  final int page;
  final int limit;

  OrdersResponse({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final ordersList = (json['orders'] as List<dynamic>)
        .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
        .toList();
    return OrdersResponse(
      orders: ordersList,
      total: json['total'] as int? ?? ordersList.length,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? ordersList.length,
    );
  }
}
