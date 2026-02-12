import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/market_model.dart';
import '../models/market_category_model.dart';
import '../models/market_product_item.dart';
import '../services/markets_service.dart';

class MarketsController extends GetxController {
  final MarketsService _marketsService = MarketsService();

  // Observable state
  final RxList<Market> _markets = <Market>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxString _errorMessage = ''.obs;

  // Categories for selection (filter chips)
  final RxList<MarketCategory> _categories = <MarketCategory>[].obs;
  final Rx<String?> _selectedCategoryId = Rx<String?>(null);
  final RxBool _isLoadingCategories = false.obs;

  // First market products (shown in the first card)
  final RxList<MarketProductItem> _firstMarketProducts =
      <MarketProductItem>[].obs;
  final RxInt _firstMarketProductCount = 0.obs;
  final RxBool _isLoadingFirstMarketProducts = false.obs;

  // User location
  final Rx<double?> _userLat = Rx<double?>(null);
  final Rx<double?> _userLong = Rx<double?>(null);

  // Getters
  List<Market> get markets => _markets;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get searchQuery => _searchQuery.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  String get errorMessage => _errorMessage.value;
  bool get hasMore => _currentPage.value < _totalPages.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  // Categories getters
  List<MarketCategory> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId.value;
  bool get isLoadingCategories => _isLoadingCategories.value;

  // First market products getters
  List<MarketProductItem> get firstMarketProducts => _firstMarketProducts;
  int get firstMarketProductCount => _firstMarketProductCount.value;
  bool get isLoadingFirstMarketProducts => _isLoadingFirstMarketProducts.value;

  // Location getters
  double? get userLat => _userLat.value;
  double? get userLong => _userLong.value;

  @override
  void onInit() {
    super.onInit();
    // Default location (Tripoli) for testing
    _userLat.value = 32.8872;
    _userLong.value = 13.1913;

    Future.microtask(() {
      fetchCategories();
      fetchMarkets();
    });
  }

  /// Fetch categories for filter chips
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

  /// Select category (null = "الكل" / all)
  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId.value == categoryId) return;
    _selectedCategoryId.value = categoryId;
    _currentPage.value = 1;
    await fetchMarkets(refresh: true);
  }

  /// Fetch markets (initial load or refresh)
  Future<void> fetchMarkets({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final MarketsResponse response;
      final categoryId = _selectedCategoryId.value;
      if (categoryId != null && categoryId.isNotEmpty) {
        response = await _marketsService.getMarketsByCategory(
          categoryId,
          page: _currentPage.value,
          limit: 10,
        );
      } else {
        response = await _marketsService.getMarkets(
          page: _currentPage.value,
          limit: 10,
          search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
        );
      }

      if (refresh) {
        _markets.value = response.data;
      } else {
        _markets.assignAll(response.data);
      }

      if (response.pagination != null) {
        _totalPages.value = response.pagination!.totalPages;
        _currentPage.value = response.pagination!.page;
      } else {
        // No pagination: assume single page
        _totalPages.value = 1;
        _currentPage.value = 1;
      }

      // Fetch products for the first market to show featured products
      _fetchFirstMarketProducts();
    } catch (e) {
      _errorMessage.value = 'فشل تحميل الماركتات: ${e.toString()}';
      showSnackBar(message: _errorMessage.value, isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load more markets (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;

    try {
      _isLoadingMore.value = true;
      _errorMessage.value = '';

      final nextPage = _currentPage.value + 1;
      final categoryId = _selectedCategoryId.value;

      final MarketsResponse response;
      if (categoryId != null && categoryId.isNotEmpty) {
        response = await _marketsService.getMarketsByCategory(
          categoryId,
          page: nextPage,
          limit: 10,
        );
      } else {
        response = await _marketsService.getMarkets(
          page: nextPage,
          limit: 10,
          search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
        );
      }

      _markets.addAll(response.data);
      if (response.pagination != null) {
        _totalPages.value = response.pagination!.totalPages;
        _currentPage.value = response.pagination!.page;
      } else {
        _totalPages.value = 1;
        _currentPage.value = 1;
      }
    } catch (e) {
      _errorMessage.value = 'فشل تحميل المزيد: ${e.toString()}';
      showSnackBar(message: _errorMessage.value, isError: true);
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Search markets
  Future<void> searchMarkets(String query) async {
    _searchQuery.value = query;
    _currentPage.value = 1;
    await fetchMarkets(refresh: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery.value = '';
    _currentPage.value = 1;
    await fetchMarkets(refresh: true);
  }

  /// Refresh markets (pull to refresh)
  Future<void> refreshMarkets() async {
    await Future.wait([
      fetchMarkets(refresh: true),
      fetchCategories(),
    ]);
  }

  /// Fetch products for the first market in the list
  Future<void> _fetchFirstMarketProducts() async {
    if (_markets.isEmpty) return;

    final marketId = _markets.first.id;
    try {
      _isLoadingFirstMarketProducts.value = true;

      final response = await _marketsService.getMarketProducts(
        marketId,
        page: 1,
        limit: 20,
      );

      _firstMarketProducts.assignAll(response.products);
      _firstMarketProductCount.value = response.products.length;
    } catch (e) {
      print('Failed to fetch products for market $marketId: $e');
    } finally {
      _isLoadingFirstMarketProducts.value = false;
    }
  }

  /// Toggle market favorite status
  Future<void> toggleFavorite(Market market) async {
    try {
      // Optimistic update
      final index = _markets.indexWhere((m) => m.id == market.id);
      if (index != -1) {
        _markets[index] = market.copyWith(
          isFavorite: !market.isFavorite,
        );
        _markets.refresh();
      }

      final isFavorite = await _marketsService.toggleFavorite(market.id);

      // Update with actual result from server
      if (index != -1) {
        _markets[index] = _markets[index].copyWith(
          isFavorite: isFavorite,
        );
        _markets.refresh();
      }

      showSnackBar(
        title: 'نجاح',
        message: isFavorite
            ? 'تمت إضافة الماركت إلى المفضلة'
            : 'تمت إزالة الماركت من المفضلة',
        isSuccess: true,
      );
    } catch (e) {
      // Revert on error
      final index = _markets.indexWhere((m) => m.id == market.id);
      if (index != -1) {
        _markets[index] = market;
        _markets.refresh();
      }

      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحديث الحالة المفضلة',
        isError: true,
      );
    }
  }
}
