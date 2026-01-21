import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/restaurant_model.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/sub_category_model.dart';
import '../services/restaurants_service.dart';
import '../../cart/controllers/cart_controller.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantsService _restaurantsService = RestaurantsService();
  final String restaurantId;

  RestaurantDetailsController({required this.restaurantId});

  // Observable state
  final RxList<MenuCategory> _categories = <MenuCategory>[].obs;
  final Rxn<Restaurant> _restaurant = Rxn<Restaurant>();
  final RxList<SubCategory> _subCategories = <SubCategory>[].obs;
  final RxList<MenuItem> _allItems = <MenuItem>[].obs;
  final RxList<MenuItem> _filteredItems = <MenuItem>[].obs;
  
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;
  
  final RxBool _isLoadingRestaurantDetails = false.obs;
  final RxBool _isLoadingCategories = false.obs;
  final RxBool _isLoadingSubCategories = false.obs;
  final RxBool _isLoadingItems = false.obs;
  final RxBool _isAddingToCart = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<MenuCategory> get categories => _categories;
  Restaurant? get restaurant => _restaurant.value;
  List<SubCategory> get subCategories => _subCategories;
  List<MenuItem> get allItems => _allItems;
  List<MenuItem> get items => _filteredItems;
  
  String get selectedCategoryId => _selectedCategoryId.value;
  String get selectedSubCategoryId => _selectedSubCategoryId.value;
  
  bool get isLoadingRestaurantDetails => _isLoadingRestaurantDetails.value;
  bool get isLoadingCategories => _isLoadingCategories.value;
  bool get isLoadingSubCategories => _isLoadingSubCategories.value;
  bool get isLoadingItems => _isLoadingItems.value;
  bool get isAddingToCart => _isAddingToCart.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await getRestaurantDetails();
    await fetchCategories();
    await fetchItems();
  }

  bool isItemFavorite(String itemId) {
    return _allItems.firstWhereOrNull((i) => i.id == itemId)?.isFav ?? false;
  }


  Future<void> toggleFavorite(String itemId) async {
    final index = _allItems.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    
    final currentItem = _allItems[index];
    final bool wasFav = currentItem.isFav;
    
    try {
      // Optimistic update
      _allItems[index] = currentItem.copyWith(isFav: !wasFav);
      _filterItems();

      if (wasFav) {
        await _restaurantsService.removeFromFavorites(itemId);
      } else {
        await _restaurantsService.addToFavorites(itemId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Rollback on error
      final rollbackIndex = _allItems.indexWhere((i) => i.id == itemId);
      if (rollbackIndex != -1) {
        _allItems[rollbackIndex] = _allItems[rollbackIndex].copyWith(isFav: wasFav);
        _filterItems();
      }
    }
  }

  Future<void> getRestaurantDetails() async {
    try {
      _isLoadingRestaurantDetails.value = true; // Or use a separate loading for restaurant details?
      _errorMessage.value = '';
      final restaurant = await _restaurantsService.getRestaurantDetails(restaurantId);
      _restaurant.value = restaurant;
    } catch (e) {
      _errorMessage.value = 'فشل تحميل بيانات المطعم: ${e.toString()}';
    } finally {
      _isLoadingRestaurantDetails.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      _isLoadingCategories.value = true;
      _errorMessage.value = '';
      final categories = await _restaurantsService.getMenuCategories(restaurant!.user.id);
      _categories.assignAll(categories);
    } catch (e) {
      _errorMessage.value = 'فشل تحميل التصنيفات: ${e.toString()}';
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  Future<void> fetchItems() async {
    try {
      _isLoadingItems.value = true;
      _errorMessage.value = '';
      final items = await _restaurantsService.getMenuItems(restaurant!.user.id);
      
      // Sort items based on category order
      if (_categories.isNotEmpty) {
        items.sort((a, b) {
          var indexA = _categories.indexWhere((c) => c.id == a.categoryId);
          var indexB = _categories.indexWhere((c) => c.id == b.categoryId);
          
          // Put items with unknown categories at the end
          if (indexA == -1) indexA = 999999;
          if (indexB == -1) indexB = 999999;
          
          return indexA.compareTo(indexB);
        });
      }

      _allItems.assignAll(items);
      _filterItems();
    } catch (e) {
      _errorMessage.value = 'فشل تحميل الأصناف: ${e.toString()}';
    } finally {
      _isLoadingItems.value = false;
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (_selectedCategoryId.value == categoryId) {
      _selectedCategoryId.value = ''; // Deselect if same
      _subCategories.clear();
      _selectedSubCategoryId.value = '';
    } else {
      _selectedCategoryId.value = categoryId;
      _selectedSubCategoryId.value = '';
      await fetchSubCategories(categoryId);
    }
    // As per user request: selecting a category does NOT filter "All Items"
    _filterItems(); 
  }

  Future<void> fetchSubCategories(String categoryId) async {
    try {
      _isLoadingSubCategories.value = true;
      final subCats = await _restaurantsService.getSubCategories(categoryId);
      _subCategories.assignAll(subCats);
    } catch (e) {
      print('Error fetching subcategories: $e');
    } finally {
      _isLoadingSubCategories.value = false;
    }
  }

  void selectSubCategory(String subCategoryId) {
    if (_selectedSubCategoryId.value == subCategoryId) {
      _selectedSubCategoryId.value = '';
    } else {
      _selectedSubCategoryId.value = subCategoryId;
    }
    _filterItems();
  }

  void _filterItems() {
    // If no subcategory is selected, show all items (or filter by category if that was intended, 
    // but user said "All items has no relation to category selection")
    // Let's assume subcategory selection DOES filter items.
    
    if (_selectedSubCategoryId.value.isEmpty) {
      // If we want to filter by category when NO subcategory is selected, we can uncomment below.
      // However, user said "جميع الاصناف ليس لها علاقة بالضغط على كاتيجوري معين"
      // So if no subcategory is selected, we show everything? 
      // Or maybe we filter by category but the user felt it was wrong?
      // "جميع الاصناف ليس لها علاقة بالضغط على كاتيجوري معين" -> This means 
      // selecting a category shouldn't filter the bottom list.
      
      _filteredItems.assignAll(_allItems);
    } else {
      // Filter by subcategory (we need subCategoryId in MenuItem model maybe? 
      // I added it to the model earlier)
      _filteredItems.assignAll(
        _allItems.where((item) => item.variations.any((v) => v.id == _selectedSubCategoryId.value)).toList(), 
      );
      // Actually, let's fetch from API to be safe if local model doesn't have subcategory yet 
      // or if it's complex.
      _fetchFilteredItems();
    }
  }

  Future<void> _fetchFilteredItems() async {
    try {
      _isLoadingItems.value = true;
      final items = await _restaurantsService.getMenuItems(
        restaurant!.user.id,
        categoryId: _selectedCategoryId.value,
        subCategoryId: _selectedSubCategoryId.value,
      );
      _filteredItems.assignAll(items);
    } catch (e) {
      print('Error fetching filtered items: $e');
    } finally {
      _isLoadingItems.value = false;
    }
  }

  Future<void> addToCart({
    required String itemId,
    required int quantity,
    required List<String> selectedVariations,
    required List<String> selectedAddOns,
    String? notes,
  }) async {
    try {
      _isAddingToCart.value = true;
      await _restaurantsService.addToCart(
        itemId: itemId,
        quantity: quantity,
        selectedVariations: selectedVariations,
        selectedAddOns: selectedAddOns,
        notes: notes,
      );
      
      // Refresh cart controller if it exists
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().refreshCarts();
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

  void clearFilters() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    _subCategories.clear();
    _filterItems();
  }

  Future<void> refreshData() async {
    await fetchInitialData();
  }
}
