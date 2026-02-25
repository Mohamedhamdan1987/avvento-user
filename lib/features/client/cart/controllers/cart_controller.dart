import 'package:avvento/core/utils/logger.dart';
import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/routes/app_routes.dart';
import '../../restaurants/services/restaurants_service.dart';
import '../../markets/services/markets_service.dart';
import '../../markets/models/market_cart_model.dart';
import '../models/cart_model.dart';
import '../models/calculate_price_model.dart';
import '../../orders/services/orders_service.dart';
import '../../orders/models/order_model.dart';
import '../../restaurants/models/menu_item_model.dart';
import '../../../../core/enums/order_status.dart';

class CartController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();
  final MarketsService _marketsService = MarketsService();
  final OrdersService _ordersService = OrdersService();

  final RxList<RestaurantCartResponse> _carts = <RestaurantCartResponse>[].obs;
  final RxList<MarketCartResponse> _marketCarts = <MarketCartResponse>[].obs;
  final Rx<RestaurantCartResponse?> _detailedCart = Rx<RestaurantCartResponse?>(null);
  final Rx<CalculatePriceResponse?> calculatedPrice = Rx<CalculatePriceResponse?>(null); // Store calculated price
  final RxList<MenuItem> _drinks = <MenuItem>[].obs; // Add drinks list
  final RxList<Map<String, dynamic>> selectedDrinks = <Map<String, dynamic>>[].obs; // Selected drinks for order
  final RxBool _isLoading = false.obs;
  final RxBool _isCalculatingPrice = false.obs; // Add loading state for price calculation
  final RxBool _isLoadingDrinks = false.obs; // Add loading state for drinks
  final RxInt _updatingItemIndex = (-1).obs;
  final RxSet<String> _updatingItemIds = <String>{}.obs;
  final RxString _errorMessage = ''.obs;

  List<RestaurantCartResponse> get carts => _carts;
  List<MarketCartResponse> get marketCarts => _marketCarts;
  int get totalCartCount => _carts.length + _marketCarts.length;
  bool get allCartsEmpty => _carts.isEmpty && _marketCarts.isEmpty;
  RestaurantCartResponse? get detailedCart => _detailedCart.value;
  List<MenuItem> get drinks => _drinks; // Getter for drinks
  bool get isLoading => _isLoading.value;
  bool get isCalculatingPrice => _isCalculatingPrice.value; // Getter for price calculation loading
  bool get isLoadingDrinks => _isLoadingDrinks.value; // Getter for drinks loading
  int get updatingItemIndex => _updatingItemIndex.value;
  bool isItemUpdating(String itemId) => _updatingItemIds.contains(itemId);
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchAllCarts());
  }

  Future<void> fetchAllCarts() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final results = await Future.wait([
        _restaurantsService.getAllCarts(),
        _marketsService.getAllMarketCarts(),
      ]);
      _carts.assignAll(results[0] as List<RestaurantCartResponse>);
      _marketCarts.assignAll(results[1] as List<MarketCartResponse>);
    } catch (e) {
      _errorMessage.value = 'فشل تحميل السلة';
      print('Error fetching carts: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchRestaurantCart(String restaurantId, {bool showLoading = true}) async {
    cprint("Fetching cart for restaurantId: $restaurantId");
    if (showLoading) {
      _isLoading.value = true;
      // Only clear data on initial load (when no data exists yet)
      if (_detailedCart.value == null) {
        _errorMessage.value = '';
      }
    }
    _errorMessage.value = '';
    try {
      final cart = await _restaurantsService.getRestaurantCart(restaurantId);
      _detailedCart.value = cart;
      
      // Fetch drinks when cart is loaded
      fetchDrinks(restaurantId);
    } catch (e) {
      // Only set error if we don't have existing data to show
      if (_detailedCart.value == null) {
        _errorMessage.value = 'فشل تحميل بيانات السلة';
      }
      print('Error fetching restaurant cart: $e');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  Future<void> fetchDrinks(String restaurantId) async {
    _isLoadingDrinks.value = true;
    try {
      final fetchedDrinks = await _restaurantsService.getDrinks(restaurantId);
      _drinks.assignAll(fetchedDrinks);
    } catch (e) {
      print('Error fetching drinks: $e');
    } finally {
      _isLoadingDrinks.value = false;
    }
  }

  Future<void> updateQuantity({
    required String restaurantId,
    required int itemIndex,
    required int quantity,
    String? notes,
  }) async {
    _updatingItemIndex.value = itemIndex;
    try {
      final updatedCart = await _restaurantsService.updateCartItem(
        restaurantId: restaurantId,
        itemIndex: itemIndex,
        quantity: quantity,
        notes: notes,
      );
      // Update detailed cart immediately
      _detailedCart.value = updatedCart;
      // Keep loading until carts are refreshed and UI gets new quantity
      await fetchAllCarts();
    } catch (e) {
      print('Error updating quantity: $e');
      showSnackBar(message: 'فشل تحديث الكمية', isError: true);
    } finally {
      _updatingItemIndex.value = -1;
    }
  }

  Future<void> removeItem(String restaurantId, int itemIndex) async {
    try {
      final updatedCart = await _restaurantsService.removeCartItem(restaurantId, itemIndex);
      // Update detailed cart immediately
      _detailedCart.value = updatedCart;
      // Keep loading until carts are refreshed and UI reflects deletion
      await fetchAllCarts();
    } catch (e) {
      print('Error removing item: $e');
      showSnackBar(message: 'فشل حذف المنتج', isError: true);
    }
  }

  Future<void> clearCart(String restaurantId) async {
    try {
      _isLoading.value = true;
      await _restaurantsService.clearCart(restaurantId);
      
      // Close the dialog and the page BEFORE updating state to avoid UI flicker
      if (Get.isOverlaysOpen) Get.back(); // Close dialog
      Get.back(); // Close details page
      
      // Now update the states
      _detailedCart.value = null;
      await fetchAllCarts();
      
      showSnackBar(message: 'تم مسح السلة بنجاح', isSuccess: true);
    } catch (e) {
      print('Error clearing cart: $e');
      if (Get.isOverlaysOpen) Get.back(); // Close dialog on error too
      showSnackBar(message: 'فشل مسح السلة', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshCarts() {
    fetchAllCarts();
  }

  /// Helper to find an item index in a specific restaurant's cart
  int getItemIndexInCart(String restaurantId, String itemId) {
    final cart = _carts.firstWhereOrNull((c) => c.restaurant.restaurantId == restaurantId || c.restaurant.id == restaurantId);
    if (cart == null) return -1;
    return cart.items.indexWhere((i) => i.item.id == itemId);
  }

  /// Helper to get an item's quantity in a specific restaurant's cart
  int getItemQuantityInCart(String restaurantId, String itemId) {
    final cart = _carts.firstWhereOrNull((c) => c.restaurant.restaurantId == restaurantId || c.restaurant.id == restaurantId);
    if (cart == null) return 0;
    final item = cart.items.firstWhereOrNull((i) => i.item.id == itemId);
    return item?.quantity ?? 0;
  }

  /// Mark an item as currently updating (for UI loading indicators)
  void setItemUpdating(String itemId) => _updatingItemIds.add(itemId);

  /// Clear an item's updating state
  void clearItemUpdating(String itemId) => _updatingItemIds.remove(itemId);

  /// Helper to update quantity using restaurantId and itemIndex
  Future<void> updateCartItemQuantity(String restaurantId, int itemIndex, int quantity) async {
    await updateQuantity(
      restaurantId: restaurantId,
      itemIndex: itemIndex,
      quantity: quantity,
    );
  }

  // Temporary drinks management
  void addDrink(MenuItem drink, int quantity, String notes) {
    selectedDrinks.add({
      "drinkId": drink.id,
      "quantity": quantity,
      "notes": notes,
      // Store display details
      "name": drink.name,
      "price": drink.price,
      "image": drink.image,
    });
  }

  void removeDrink(int index) {
    if (index >= 0 && index < selectedDrinks.length) {
      selectedDrinks.removeAt(index);
    }
  }

  void clearDrinks() {
    selectedDrinks.clear();
  }

  Future<void> calculateOrderPrice({
    required String restaurantId,
    required String addressId,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLong,
    required String paymentMethod,
  }) async {
    _isCalculatingPrice.value = true;
    _errorMessage.value = '';
    try {
      // Clean drinks list to only send required fields
      final drinksPayload = selectedDrinks.map((d) => {
        "drinkId": d["drinkId"],
        "quantity": d["quantity"],
        "notes": d["notes"],
      }).toList();

      final result = await _ordersService.calculatePrice(
        restaurantId: restaurantId,
        addressId: addressId,
        deliveryAddress: deliveryAddress,
        deliveryLat: deliveryLat,
        deliveryLong: deliveryLong,
        paymentMethod: paymentMethod,
        drinks: drinksPayload.isNotEmpty ? drinksPayload : null,
      );
      calculatedPrice.value = result;
    } catch (e) {
      print('Error calculating price: $e');
    } finally {
      _isCalculatingPrice.value = false;
    }
  }

  Future<void> placeOrder({
    required String restaurantId,
    required String addressId,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLong,
    double? restaurantLat,
    double? restaurantLong,
    required String payment,
    String? paymentGatewayTransactionId,
    String? notes,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      // Clean drinks list to only send required fields
      final drinksPayload = selectedDrinks.map((d) => {
        "drinkId": d["drinkId"],
        "quantity": d["quantity"],
        "notes": d["notes"],
      }).toList();

      final order = await _ordersService.createOrder(
        restaurantId: restaurantId,
        addressId: addressId,
        deliveryAddress: deliveryAddress,
        deliveryLat: deliveryLat,
        deliveryLong: deliveryLong,
        payment: payment,
        paymentGatewayTransactionId: paymentGatewayTransactionId,
        notes: notes,
        drinks: drinksPayload.isNotEmpty ? drinksPayload : null,
      );
      
      // Clear the cart for this restaurant locally and refresh
      _detailedCart.value = null;
      await fetchAllCarts();
      
      showSnackBar(message: 'تم إرسال طلبك بنجاح', isSuccess: true);
      
      // Navigate to order tracking page
      if (restaurantLat != null && restaurantLong != null) {
        Get.offAllNamed(
          AppRoutes.orderTrackingMap,
          arguments: {
            'userLat': deliveryLat,
            'userLong': deliveryLong,
            'restaurantLat': restaurantLat,
            'restaurantLong': restaurantLong,
            'orderId': order.id,
            'status': OrderStatus.fromString(order.status),
            'driverName': order.driver?.name,
            'driverPhone': order.driver?.phone,
            'driverImageUrl': order.driver?.image,
          },
        );
      } else {
        // Fallback if coordinates missing
        Get.offAllNamed(AppRoutes.clientNavBar, arguments: {'tabIndex': 1}); 
      }
    } catch (e) {
      _errorMessage.value = 'فشل إتمام الطلب';
      print('Error placing order: $e');
      showSnackBar(message: 'فشل إرسال الطلب، يرجى المحاولة مرة أخرى', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }
}
