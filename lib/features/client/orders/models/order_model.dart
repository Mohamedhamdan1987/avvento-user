class OrderItem {
  final String itemId;
  final int quantity;
  final List<String> selectedVariations;
  final List<String> selectedAddOns;
  final String notes;
  final double unitPrice;
  final double totalPrice;
  final String id;

  OrderItem({
    required this.itemId,
    required this.quantity,
    required this.selectedVariations,
    required this.selectedAddOns,
    required this.notes,
    required this.unitPrice,
    required this.totalPrice,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle item as Map (populated) or String (ID)
    // Also check for 'drink' key as fallback if 'item' is missing (for drinks added to order)
    dynamic itemData = json['item'] ?? json['drink'];
    
    final itemId = itemData is Map 
        ? (itemData as Map<String, dynamic>)['_id'] as String
        : (itemData as String? ?? '');
        
    return OrderItem(
      itemId: itemId,
      quantity: json['quantity'] as int? ?? 0,
      selectedVariations: List<String>.from(json['selectedVariations'] ?? []),
      selectedAddOns: List<String>.from(json['selectedAddOns'] ?? []),
      notes: json['notes'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      id: json['_id'] as String? ?? '',
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

    return OrderModel(
      id: json['_id'] as String,
      userId: userId,
      restaurant: OrderRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      deliveryAddress: json['deliveryAddress'] is Map 
          ? (json['deliveryAddress'] as Map<String, dynamic>)['address'] as String? // Assuming structure if populated
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
    return OrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
