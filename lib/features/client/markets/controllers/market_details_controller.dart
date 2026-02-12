import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/market_model.dart';
import '../models/market_category_model.dart';
import '../models/market_product_item.dart';
import '../services/markets_service.dart';
import 'market_cart_controller.dart';

class MarketDetailsController extends GetxController {
  final MarketsService _marketsService = MarketsService();
  final String marketId;

  MarketDetailsController({required this.marketId});

  // Observable state
  final Rxn<Market> _market = Rxn<Market>();
  final RxList<MarketProductItem> _products = <MarketProductItem>[].obs;
  final RxList<MarketCategory> _categories = <MarketCategory>[].obs;
  final Rxn<String> _selectedCategoryId = Rxn<String>();

  final RxBool _isLoadingMarketDetails = false.obs;
  final RxBool _isLoadingProducts = false.obs;
  final RxBool _isLoadingCategories = false.obs;
  final RxBool _isAddingToCart = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  Market? get market => _market.value;
  List<MarketProductItem> get products => _products;
  List<MarketCategory> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId.value;

  bool get isLoadingMarketDetails => _isLoadingMarketDetails.value;
  bool get isLoadingProducts => _isLoadingProducts.value;
  bool get isLoadingCategories => _isLoadingCategories.value;
  bool get isAddingToCart => _isAddingToCart.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchInitialData());
  }

  Future<void> fetchInitialData() async {
    await getMarketDetails();
    if (market != null) {
      await Future.wait([
        fetchCategories(),
        fetchProducts(),
      ]);
    }
  }

  Future<void> getMarketDetails() async {
    try {
      _isLoadingMarketDetails.value = true;
      _errorMessage.value = '';
      final marketData = await _marketsService.getMarketDetails(marketId);
      _market.value = marketData;
    } catch (e) {
      _errorMessage.value = 'فشل تحميل بيانات المتجر: ${e.toString()}';
    } finally {
      _isLoadingMarketDetails.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      _isLoadingCategories.value = true;
      final list = await _marketsService.getMarketCategories();
      _categories.assignAll(list);
    } catch (e) {
      print('Failed to fetch market categories: $e');
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts({String? categoryId}) async {
    try {
      _isLoadingProducts.value = true;
      _errorMessage.value = '';
      final response = await _marketsService.getMarketProducts(
        marketId,
        page: 1,
        limit: 100,
        categoryId: categoryId,
      );
      _products.assignAll(response.products);
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المنتجات: ${e.toString()}';
    } finally {
      _isLoadingProducts.value = false;
    }
  }

  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId.value == categoryId) {
      _selectedCategoryId.value = null;
      await fetchProducts();
    } else {
      _selectedCategoryId.value = categoryId;
      await fetchProducts(categoryId: categoryId);
    }
  }

  Future<void> addToCart({
    required String marketProductId,
    required int quantity,
    String? notes,
  }) async {
    try {
      _isAddingToCart.value = true;
      await _marketsService.addProductToCart(
        marketId: marketId,
        marketProductId: marketProductId,
        quantity: quantity,
        notes: notes,
      );

      // Refresh market cart controller if it exists
      if (Get.isRegistered<MarketCartController>()) {
        Get.find<MarketCartController>().refreshCarts();
      }

      showSnackBar(
        title: 'نجاح',
        message: 'تم إضافة المنتج للسلة بنجاح',
        isSuccess: true,
      );
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'فشل إضافة المنتج للسلة',
        isError: true,
      );
    } finally {
      _isAddingToCart.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchInitialData();
  }
}
