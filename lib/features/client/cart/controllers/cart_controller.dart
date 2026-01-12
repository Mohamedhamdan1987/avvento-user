import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../restaurants/services/restaurants_service.dart';
import '../models/cart_model.dart';
import '../../orders/services/orders_service.dart';
import '../../orders/models/order_model.dart';
import '../../restaurants/models/menu_item_model.dart';

class CartController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();
  final OrdersService _ordersService = OrdersService();

  final RxList<RestaurantCartResponse> _carts = <RestaurantCartResponse>[].obs;
  final Rx<RestaurantCartResponse?> _detailedCart = Rx<RestaurantCartResponse?>(null);
  final RxList<MenuItem> _drinks = <MenuItem>[].obs; // Add drinks list
  final RxList<Map<String, dynamic>> selectedDrinks = <Map<String, dynamic>>[].obs; // Selected drinks for order
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingDrinks = false.obs; // Add loading state for drinks
  final RxInt _updatingItemIndex = (-1).obs;
  final RxString _errorMessage = ''.obs;

  List<RestaurantCartResponse> get carts => _carts;
  RestaurantCartResponse? get detailedCart => _detailedCart.value;
  List<MenuItem> get drinks => _drinks; // Getter for drinks
  bool get isLoading => _isLoading.value;
  bool get isLoadingDrinks => _isLoadingDrinks.value; // Getter for drinks loading
  int get updatingItemIndex => _updatingItemIndex.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchAllCarts();
  }

  Future<void> fetchAllCarts() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final fetchedCarts = await _restaurantsService.getAllCarts();
      _carts.assignAll(fetchedCarts);
    } catch (e) {
      _errorMessage.value = 'فشل تحميل السلة';
      print('Error fetching carts: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchRestaurantCart(String restaurantId, {bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.value = true;
      _detailedCart.value = null; // Clear old data to prevent build errors
    }
    _errorMessage.value = '';
    try {
      final cart = await _restaurantsService.getRestaurantCart(restaurantId);
      _detailedCart.value = cart;
      
      // Fetch drinks when cart is loaded
      fetchDrinks(restaurantId);
    } catch (e) {
      if (showLoading) _errorMessage.value = 'فشل تحميل بيانات السلة';
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
      // Refresh overall carts in background
      fetchAllCarts(); 
    } catch (e) {
      print('Error updating quantity: $e');
      Get.snackbar('خطأ', 'فشل تحديث الكمية');
    } finally {
      _updatingItemIndex.value = -1;
    }
  }

  Future<void> removeItem(String restaurantId, int itemIndex) async {
    try {
      final updatedCart = await _restaurantsService.removeCartItem(restaurantId, itemIndex);
      // Update detailed cart immediately
      _detailedCart.value = updatedCart;
      // Refresh overall carts in background
      fetchAllCarts();
    } catch (e) {
      print('Error removing item: $e');
      Get.snackbar('خطأ', 'فشل حذف المنتج');
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
      
      Get.snackbar('نجاح', 'تم مسح السلة بنجاح');
    } catch (e) {
      print('Error clearing cart: $e');
      if (Get.isOverlaysOpen) Get.back(); // Close dialog on error too
      Get.snackbar('خطأ', 'فشل مسح السلة');
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshCarts() {
    fetchAllCarts();
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

  Future<void> placeOrder({
    required String restaurantId,
    required String addressId,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLong,
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
      
      Get.snackbar('نجاح', 'تم إرسال طلبك بنجاح');
      
      // Navigate to order details or success page
      // For now, let's just go back to the restaurants list or orders page
      Get.offAllNamed(AppRoutes.clientNavBar); 
    } catch (e) {
      _errorMessage.value = 'فشل إتمام الطلب';
      print('Error placing order: $e');
      Get.snackbar('خطأ', 'فشل إرسال الطلب، يرجى المحاولة مرة أخرى');
    } finally {
      _isLoading.value = false;
    }
  }
}
