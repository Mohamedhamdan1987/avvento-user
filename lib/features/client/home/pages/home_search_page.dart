import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../../restaurants/services/restaurants_service.dart';
import '../../restaurants/pages/restaurant_details_screen.dart';
import '../../markets/models/market_model.dart';
import '../../markets/services/markets_service.dart';
import '../../markets/pages/market_details_page.dart';

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({super.key});

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final RestaurantsService _restaurantsService = RestaurantsService();
  final MarketsService _marketsService = MarketsService();

  final RxList<Restaurant> _restaurants = <Restaurant>[].obs;
  final RxList<Market> _markets = <Market>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _query = ''.obs;

  Timer? _debounce;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _query.value = _searchController.text;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _restaurants.clear();
      _markets.clear();
      return;
    }

    _isLoading.value = true;
    try {
      final results = await Future.wait([
        _restaurantsService.getRestaurants(search: query, limit: 20),
        _marketsService.getMarkets(search: query, limit: 20),
      ]);

      _restaurants.assignAll((results[0] as RestaurantsResponse).data);
      _markets.assignAll((results[1] as MarketsResponse).data);
    } catch (_) {
      // silently fail
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsetsDirectional.only(start: 16.w),
          child: _buildSearchBar(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: const TextStyle().textColorMedium(
                fontSize: 14.sp,
                color: AppColors.purple,
              ),
            ),
          ),
          SizedBox(width: 4.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(46.h),
          child: Obx(() {
            if (_query.value.isEmpty) return const SizedBox.shrink();
            return Directionality(
              textDirection: TextDirection.rtl,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.purple,
                unselectedLabelColor: Theme.of(context).hintColor,
                indicatorColor: AppColors.purple,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle().textColorMedium(
                  fontSize: 13.sp,
                  color: AppColors.purple,
                ),
                unselectedLabelStyle: const TextStyle().textColorNormal(
                  fontSize: 13.sp,
                  color: Theme.of(context).hintColor,
                ),
                tabs: [
                  Tab(
                    text:
                        'الكل (${_restaurants.length + _markets.length})',
                  ),
                  Tab(text: 'المطاعم (${_restaurants.length})'),
                  Tab(text: 'الماركتات (${_markets.length})'),
                ],
              ),
            );
          }),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (_query.value.isEmpty) {
            return _buildEmptyState();
          }
          if (_isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            );
          }
          if (_restaurants.isEmpty && _markets.isEmpty) {
            return _buildNoResults();
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllResults(),
              _buildRestaurantsList(),
              _buildMarketsList(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style:
            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن مطعم أو ماركت...',
          hintStyle: const TextStyle().textColorNormal(
            fontSize: 14.sp,
            color: Theme.of(context).hintColor,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: SvgPicture.asset(
              'assets/svg/client/home/search.svg',
              width: 18.w,
              height: 18.h,
              colorFilter: ColorFilter.mode(
                Theme.of(context).hintColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon: Obx(() {
            if (_query.value.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () {
                _searchController.clear();
              },
              child: Icon(Icons.close, size: 20.r, color: Theme.of(context).hintColor),
            );
          }),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/client/home/search.svg',
            width: 64.w,
            height: 64.h,
            colorFilter: ColorFilter.mode(
              Theme.of(context).disabledColor.withOpacity(0.4),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'ابحث عن مطاعم أو ماركتات',
            style: const TextStyle().textColorMedium(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.r, color: Theme.of(context).disabledColor),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نتائج مطابقة',
            style: const TextStyle().textColorMedium(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── All Results Tab ────────────────────────────────────────────

  Widget _buildAllResults() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      children: [
        if (_restaurants.isNotEmpty) ...[
          _buildSectionTitle('المطاعم'),
          SizedBox(height: 8.h),
          ..._restaurants.map((r) => _buildRestaurantCard(r)),
          SizedBox(height: 20.h),
        ],
        if (_markets.isNotEmpty) ...[
          _buildSectionTitle('الماركتات'),
          SizedBox(height: 8.h),
          ..._markets.map((m) => _buildMarketCard(m)),
        ],
      ],
    );
  }

  // ─── Restaurants Tab ────────────────────────────────────────────

  Widget _buildRestaurantsList() {
    if (_restaurants.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مطاعم مطابقة',
          style: const TextStyle().textColorMedium(
            fontSize: 14.sp,
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) => _buildRestaurantCard(_restaurants[index]),
    );
  }

  // ─── Markets Tab ────────────────────────────────────────────────

  Widget _buildMarketsList() {
    if (_markets.isEmpty) {
      return Center(
        child: Text(
          'لا توجد ماركتات مطابقة',
          style: const TextStyle().textColorMedium(
            fontSize: 14.sp,
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _markets.length,
      itemBuilder: (context, index) => _buildMarketCard(_markets[index]),
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle().textColorBold(
        fontSize: 16.sp,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () => Get.to(
          () => RestaurantDetailsScreen(restaurantId: restaurant.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 56.w,
                height: 56.w,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: restaurant.logo != null && restaurant.logo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: restaurant.logo!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: Icon(Icons.restaurant,
                              size: 24.r, color: Theme.of(context).hintColor),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.restaurant,
                              size: 24.r, color: Theme.of(context).hintColor),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.restaurant,
                            size: 24.r, color: Theme.of(context).hintColor),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle().textColorMedium(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 14.r, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        restaurant.averageRatingDisplay,
                        style: const TextStyle().textColorNormal(
                          fontSize: 12.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: restaurant.isOpen
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          restaurant.isOpen ? 'مفتوح' : 'مغلق',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: restaurant.isOpen
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Type badge
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'مطعم',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketCard(Market market) {
    return GestureDetector(
      onTap: () => Get.to(() => MarketDetailsPage(marketId: market.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 56.w,
                height: 56.w,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: market.logo != null && market.logo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: market.logo!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: Icon(Icons.store,
                              size: 24.r, color: Theme.of(context).hintColor),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.store,
                              size: 24.r, color: Theme.of(context).hintColor),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.store,
                            size: 24.r, color: Theme.of(context).hintColor),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.name,
                    style: const TextStyle().textColorMedium(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 14.r, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        market.averageRatingDisplay,
                        style: const TextStyle().textColorNormal(
                          fontSize: 12.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: market.isOpen
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          market.isOpen ? 'مفتوح' : 'مغلق',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color:
                                market.isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (market.hasFreeDelivery) ...[
                        SizedBox(width: 8.w),
                        Text(
                          'توصيل مجاني',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Type badge
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'ماركت',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
