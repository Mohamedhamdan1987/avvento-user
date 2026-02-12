import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/market_cart_model.dart';
import '../services/markets_service.dart';

class MarketCartController extends GetxController {
  final MarketsService _marketsService = MarketsService();

  final RxList<MarketCartResponse> _carts = <MarketCartResponse>[].obs;
  final Rx<MarketCartResponse?> _detailedCart = Rx<MarketCartResponse?>(null);
  final RxBool _isLoading = false.obs;
  final RxInt _updatingProductIndex = (-1).obs;
  final RxString _errorMessage = ''.obs;

  List<MarketCartResponse> get carts => _carts;
  MarketCartResponse? get detailedCart => _detailedCart.value;
  bool get isLoading => _isLoading.value;
  int get updatingProductIndex => _updatingProductIndex.value;
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
      final fetchedCarts = await _marketsService.getAllMarketCarts();
      _carts.assignAll(fetchedCarts);
    } catch (e) {
      _errorMessage.value = 'فشل تحميل السلة';
      print('Error fetching market carts: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchMarketCart(String marketId,
      {bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.value = true;
      _detailedCart.value = null;
    }
    _errorMessage.value = '';
    try {
      final cart = await _marketsService.getMarketCart(marketId);
      _detailedCart.value = cart;
    } catch (e) {
      if (showLoading) _errorMessage.value = 'فشل تحميل بيانات السلة';
      print('Error fetching market cart: $e');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  Future<void> updateQuantity({
    required String marketId,
    required int productIndex,
    required int quantity,
    String? notes,
  }) async {
    _updatingProductIndex.value = productIndex;
    try {
      final updatedCart = await _marketsService.updateCartProduct(
        marketId: marketId,
        productIndex: productIndex,
        quantity: quantity,
        notes: notes,
      );
      _detailedCart.value = updatedCart;
      fetchAllCarts();
    } catch (e) {
      print('Error updating quantity: $e');
      showSnackBar(message: 'فشل تحديث الكمية', isError: true);
    } finally {
      _updatingProductIndex.value = -1;
    }
  }

  Future<void> removeProduct(String marketId, int productIndex) async {
    try {
      final updatedCart =
          await _marketsService.removeCartProduct(marketId, productIndex);
      _detailedCart.value = updatedCart;
      fetchAllCarts();
    } catch (e) {
      print('Error removing product: $e');
      showSnackBar(message: 'فشل حذف المنتج', isError: true);
    }
  }

  Future<void> clearCart(String marketId) async {
    try {
      _isLoading.value = true;
      await _marketsService.clearMarketCart(marketId);

      if (Get.isOverlaysOpen) Get.back(); // Close dialog
      Get.back(); // Close details page

      _detailedCart.value = null;
      await fetchAllCarts();

      showSnackBar(message: 'تم مسح السلة بنجاح', isSuccess: true);
    } catch (e) {
      print('Error clearing cart: $e');
      if (Get.isOverlaysOpen) Get.back();
      showSnackBar(message: 'فشل مسح السلة', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  void refreshCarts() {
    fetchAllCarts();
  }

  /// Helper to find a product index in a specific market's cart
  int getProductIndexInCart(String marketId, String marketProductId) {
    final cart = _carts.firstWhereOrNull((c) => c.market.id == marketId);
    if (cart == null) return -1;
    return cart.products
        .indexWhere((p) => p.marketProduct.id == marketProductId);
  }

  /// Helper to get a product's quantity in a specific market's cart
  int getProductQuantityInCart(String marketId, String marketProductId) {
    final cart = _carts.firstWhereOrNull((c) => c.market.id == marketId);
    if (cart == null) return 0;
    final product = cart.products
        .firstWhereOrNull((p) => p.marketProduct.id == marketProductId);
    return product?.quantity ?? 0;
  }
}
