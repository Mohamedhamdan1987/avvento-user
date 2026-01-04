import 'package:get/get.dart';
import '../../restaurants/services/restaurants_service.dart';
import '../models/cart_model.dart';

class CartController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();

  final RxList<RestaurantCart> _carts = <RestaurantCart>[].obs;
  final Rx<RestaurantCart?> _detailedCart = Rx<RestaurantCart?>(null);
  final RxBool _isLoading = false.obs;
  final RxInt _updatingItemIndex = (-1).obs;
  final RxString _errorMessage = ''.obs;

  List<RestaurantCart> get carts => _carts;
  RestaurantCart? get detailedCart => _detailedCart.value;
  bool get isLoading => _isLoading.value;
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
    } catch (e) {
      if (showLoading) _errorMessage.value = 'فشل تحميل بيانات السلة';
      print('Error fetching restaurant cart: $e');
    } finally {
      if (showLoading) _isLoading.value = false;
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
}
