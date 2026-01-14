import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/restaurant_model.dart';
import 'category_menu_page.dart';
import 'meal_details_dialog.dart';
import '../services/search_history_service.dart';

class RestaurantSearchPage extends StatefulWidget {
  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> allItems;

  const RestaurantSearchPage({
    super.key,
    required this.restaurant,
    required this.categories,
    required this.allItems,
  });

  @override
  State<RestaurantSearchPage> createState() => _RestaurantSearchPageState();
}

class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<String> _history = <String>[].obs;
  final RxList<MenuCategory> _filteredCategories = <MenuCategory>[].obs;
  final RxList<MenuItem> _filteredItems = <MenuItem>[].obs;
  final RxString _query = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(() {
      _query.value = _searchController.text;
      _performSearch(_searchController.text);
    });
  }

  void _loadHistory() async {
    final history = await SearchHistoryService.getSearchHistory(widget.restaurant.id);
    _history.assignAll(history);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _filteredCategories.clear();
      _filteredItems.clear();
      return;
    }

    _filteredCategories.assignAll(
      widget.categories.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList(),
    );

    _filteredItems.assignAll(
      widget.allItems.where((i) => 
        i.name.toLowerCase().contains(query.toLowerCase()) || 
        i.description.toLowerCase().contains(query.toLowerCase())
      ).toList(),
    );
  }

  void _onQuerySubmitted(String query) {
    if (query.isNotEmpty) {
      SearchHistoryService.addToHistory(widget.restaurant.id, query);
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchBar(),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: const TextStyle().textColorMedium(
                fontSize: 14.sp,
                color: const Color(0xFF7F22FE),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (_query.value.isEmpty) {
            return _buildHistorySection();
          }
          if (_filteredCategories.isEmpty && _filteredItems.isEmpty) {
            return _buildEmptyResults();
          }
          return _buildSearchResults();
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: _onQuerySubmitted,
        decoration: InputDecoration(
          hintText: 'ابحث عن قسم أو عنصر...',
          hintStyle: const TextStyle().textColorNormal(
            fontSize: 14.sp,
            color: const Color(0xFF99A1AF),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: SvgIcon(
              iconName: 'assets/svg/search-icon.svg',
              width: 16.w,
              height: 16.h,
              color: const Color(0xFF99A1AF),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(24.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عمليات البحث الأخيرة',
                style: const TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: const Color(0xFF101828),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await SearchHistoryService.clearHistory(widget.restaurant.id);
                  _loadHistory();
                },
                child: Text(
                  'مسح الكل',
                  style: const TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: const Color(0xFF7F22FE),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: _history.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final item = _history[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SvgIcon(
                  iconName: 'assets/svg/search-icon.svg',
                  width: 16.w,
                  height: 16.h,
                  color: const Color(0xFF99A1AF),
                ),
                title: Text(
                  item,
                  style: const TextStyle().textColorNormal(
                    fontSize: 14.sp,
                    color: const Color(0xFF101828),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () async {
                    await SearchHistoryService.removeFromHistory(widget.restaurant.id, item);
                    _loadHistory();
                  },
                  child: Icon(Icons.close, size: 18.r, color: const Color(0xFF99A1AF)),
                ),
                onTap: () {
                  _searchController.text = item;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: item.length),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: [
        if (_filteredCategories.isNotEmpty) ...[
          Text(
            'الأقسام',
            style: const TextStyle().textColorBold(
              fontSize: 16.sp,
              color: const Color(0xFF101828),
            ),
          ),
          SizedBox(height: 12.h),
          ..._filteredCategories.map((category) => _buildCategoryResultCard(category)).toList(),
          SizedBox(height: 24.h),
        ],
        if (_filteredItems.isNotEmpty) ...[
          Text(
            'العناصر',
            style: const TextStyle().textColorBold(
              fontSize: 16.sp,
              color: const Color(0xFF101828),
            ),
          ),
          SizedBox(height: 12.h),
          ..._filteredItems.map((item) => _buildItemResultCard(item)).toList(),
        ],
      ],
    );
  }

  Widget _buildCategoryResultCard(MenuCategory category) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: const Color(0xFFF3F4F6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: category.image != null && category.image!.isNotEmpty
              ? CachedNetworkImage(imageUrl: category.image!, fit: BoxFit.cover)
              : Center(child: Icon(Icons.category, size: 24.r, color: const Color(0xFF99A1AF))),
        ),
      ),
      title: Text(
        category.name,
        style: const TextStyle().textColorMedium(
          fontSize: 14.sp,
          color: const Color(0xFF101828),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14.r, color: const Color(0xFF99A1AF)),
      onTap: () {
         _onQuerySubmitted(_searchController.text);
        Get.to(() => CategoryMenuPage(
          restaurant: widget.restaurant,
          category: category,
        ));
      },
    );
  }

  Widget _buildItemResultCard(MenuItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: const Color(0xFFF3F4F6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: item.image != null && item.image!.isNotEmpty
              ? CachedNetworkImage(imageUrl: item.image!, fit: BoxFit.cover)
              : Center(child: Icon(Icons.fastfood, size: 24.r, color: const Color(0xFF99A1AF))),
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle().textColorMedium(
          fontSize: 14.sp,
          color: const Color(0xFF101828),
        ),
      ),
      subtitle: Text(
        '${item.price} د.ل',
        style: const TextStyle().textColorNormal(
          fontSize: 12.sp,
          color: const Color(0xFF7F22FE),
        ),
      ),
      onTap: () {
         _onQuerySubmitted(_searchController.text);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MealDetailsDialog(menuItem: item),
        );
      },
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.r, color: const Color(0xFF99A1AF)),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نتائج مطابقة',
            style: const TextStyle().textColorMedium(
              fontSize: 16.sp,
              color: const Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }
}
