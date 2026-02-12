/// Product category info from the products API
class ProductCategory {
  final String id;
  final String name;
  final String? image;

  ProductCategory({
    required this.id,
    required this.name,
    this.image,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] as String?,
    );
  }
}

/// The actual product details (nested in the market product item)
class ProductDetails {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final ProductCategory? category;
  final String? barcode;
  final String? brand;
  final String? unit;
  final bool isActive;

  ProductDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    this.category,
    this.barcode,
    this.brand,
    this.unit,
    required this.isActive,
  });

  /// First image URL or null
  String? get firstImage => images.isNotEmpty ? images.first : null;

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      images = (json['images'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    ProductCategory? category;
    if (json['category'] != null && json['category'] is Map) {
      category = ProductCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      );
    }

    return ProductDetails(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: images,
      category: category,
      barcode: json['barcode'] as String?,
      brand: json['brand'] as String?,
      unit: json['unit'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// Brief market info inside a product item
class ProductMarketInfo {
  final String id;
  final String name;
  final String? logo;

  ProductMarketInfo({
    required this.id,
    required this.name,
    this.logo,
  });

  factory ProductMarketInfo.fromJson(Map<String, dynamic> json) {
    return ProductMarketInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] as String?,
    );
  }
}

/// A market product item from GET /markets/:id/products
class MarketProductItem {
  final String id;
  final ProductMarketInfo market;
  final ProductDetails product;
  final double price;
  final int quantity;
  final bool isAvailable;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketProductItem({
    required this.id,
    required this.market,
    required this.product,
    required this.price,
    required this.quantity,
    required this.isAvailable,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// First product image for thumbnail
  String? get thumbnailUrl => product.firstImage;

  factory MarketProductItem.fromJson(Map<String, dynamic> json) {
    return MarketProductItem(
      id: json['_id'] ?? json['id'] ?? '',
      market: ProductMarketInfo.fromJson(
        json['market'] as Map<String, dynamic>? ?? {},
      ),
      product: ProductDetails.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Response from GET /markets/:id/products
class MarketProductsResponse {
  final List<MarketProductItem> products;

  MarketProductsResponse({required this.products});

  factory MarketProductsResponse.fromJson(Map<String, dynamic> json) {
    return MarketProductsResponse(
      products: ((json['products'] ?? []) as List<dynamic>)
          .map((item) =>
              MarketProductItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
