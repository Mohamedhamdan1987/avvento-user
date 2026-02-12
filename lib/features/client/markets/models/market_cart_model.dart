import 'market_product_item.dart';

/// Cart product item from the market cart API
class MarketCartProduct {
  final String id;
  final MarketProductItem marketProduct;
  final int quantity;
  final String notes;
  final double totalPrice;

  MarketCartProduct({
    required this.id,
    required this.marketProduct,
    required this.quantity,
    required this.notes,
    required this.totalPrice,
  });

  factory MarketCartProduct.fromJson(Map<String, dynamic> json) {
    return MarketCartProduct(
      id: json['_id'] as String,
      marketProduct: MarketProductItem.fromJson(
        json['marketProduct'] as Map<String, dynamic>,
      ),
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Market info inside the cart response
class CartMarket {
  final String id;
  final String name;
  final String? address;
  final String? logo;
  final double? lat;
  final double? long;

  CartMarket({
    required this.id,
    required this.name,
    this.address,
    this.logo,
    this.lat,
    this.long,
  });

  factory CartMarket.fromJson(Map<String, dynamic> json) {
    return CartMarket(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      logo: json['logo'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      long: json['long'] != null ? (json['long'] as num).toDouble() : null,
    );
  }
}

/// Full market cart response
class MarketCartResponse {
  final String id;
  final String user;
  final CartMarket market;
  final List<MarketCartProduct> products;
  final double totalPrice;

  MarketCartResponse({
    required this.id,
    required this.user,
    required this.market,
    required this.products,
    required this.totalPrice,
  });

  factory MarketCartResponse.fromJson(Map<String, dynamic> json) {
    return MarketCartResponse(
      id: json['_id'] as String,
      user: json['user'] is String
          ? json['user'] as String
          : (json['user'] as Map<String, dynamic>?)?['_id'] ?? '',
      market: CartMarket.fromJson(json['market'] as Map<String, dynamic>),
      products: (json['products'] as List<dynamic>?)
              ?.where((p) =>
                  p != null &&
                  p is Map<String, dynamic> &&
                  p['marketProduct'] is Map<String, dynamic>)
              .map((p) => MarketCartProduct.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
