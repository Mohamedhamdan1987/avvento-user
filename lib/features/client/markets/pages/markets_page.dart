import 'package:avvento/core/utils/logger.dart';
import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/shimmer/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/markets_controller.dart';
import '../models/market_model.dart';
import '../models/market_category_model.dart';
import '../models/market_product_item.dart';
import '../../address/controllers/address_controller.dart';
import 'market_details_page.dart';

class MarketsPage extends GetView<MarketsController> {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButtonApp(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    childWidget: SvgIcon(
                      iconName: 'assets/svg/arrow-right.svg',
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          AppColors.textDark,
                    ),
                    onTap: () => Get.back(),
                  ),
                  Flexible(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Get.toNamed(AppRoutes.addressList),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'التوصيل إلى',
                              style: TextStyle(
                                color: AppColors.purple,
                                fontSize: 12,
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Obx(
                                    () => Text(
                                      "${addressController.activeAddress.value?.label ?? ''} - ${addressController.activeAddress.value?.address ?? ''}",
                                      style: const TextStyle().textColorLight(
                                        fontSize: 12,
                                        color: const Color(0xFF101727),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SvgIcon(iconName: "assets/svg/arrow_down.svg"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomIconButtonApp(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    childWidget: SvgIcon(
                      iconName: "assets/svg/wallet/wallet.svg",
                    ),
                    onTap: () {
                      Get.toNamed(AppRoutes.wallet);
                    },
                  ),
                ],
              ),
            ),

            // --- Scrollable Content (Search + Categories + Markets) ---
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.axis == Axis.vertical &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200 &&
                      controller.hasMore &&
                      !controller.isLoadingMore) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: AppRefreshIndicator(
                  onRefresh: controller.refreshMarkets,
                  child: Obx(() {
                    final sortedMarkets = controller.markets.isNotEmpty
                        ? ([...controller.markets]
                          ..sort((a, b) {
                            if (a.isOpen == b.isOpen) return 0;
                            return a.isOpen ? -1 : 1;
                          }))
                        : <Market>[];

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // --- Search Bar ---
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: controller.searchTextController,
                              onChanged: (value) {
                                // Debounce search
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    if (value == controller.searchQuery) return;
                                    controller.searchMarkets(value);
                                  },
                                );
                              },
                              decoration: InputDecoration(
                                filled: true,
                                hintText: 'ابحث عن ماركت...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: CustomIconButtonApp(
                                  childWidget: SvgIcon(
                                    iconName: "assets/svg/client/search.svg",
                                  ),
                                  onTap: () {},
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    width: 0.76,
                                    color: Color(0xFFE4E4E4),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    width: 0.76,
                                    color: Color(0xFFE4E4E4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    width: 0.76,
                                    color: Color(0xFFE4E4E4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(child: SizedBox(height: 8.h)),

                        // --- Content based on state ---
                        if (controller.isLoading && controller.markets.isEmpty)
                          _buildMarketsShimmerSliver()
                        else if (controller.hasError && controller.markets.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: controller.fetchMarkets,
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (controller.markets.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد ماركتات',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          // --- Advertisements ---
                          if (controller.advertisements.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                                child: SizedBox(
                                  height: 144.h,
                                  child: PageView.builder(
                                    controller: PageController(
                                      viewportFraction: controller.advertisements.length > 1 ? 0.92 : 1.0,
                                    ),
                                    itemCount: controller.advertisements.length,
                                    itemBuilder: (context, adIndex) {
                                      final ad = controller.advertisements[adIndex];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () {
                                            Get.toNamed(AppRoutes.marketDetails, arguments: ad.market!.id);

                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: CachedNetworkImage(
                                              imageUrl: ad.image,
                                              width: double.infinity,
                                              height: 144.h,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                    height: 144.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.image_outlined,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),


                          // --- Category Chips ---
                          SliverToBoxAdapter(
                            child: (controller.isLoadingCategories &&
                                    controller.categories.isEmpty)
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: EdgeInsetsDirectional.only(top: 12.h, bottom: 20.h, start: 10.w),
                                    child: SizedBox(
                                      height: 48.h,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 12.w),
                                            child: _MarketCategoryChip(
                                              label: 'الكل',
                                              isSelected: controller.selectedCategoryId == null,
                                              onTap: () => controller.selectCategory(null),
                                            ),
                                          ),
                                          ...controller.categories.map(
                                            (MarketCategory cat) => Padding(
                                              padding: EdgeInsets.only(left: 12.w),
                                              child: _MarketCategoryChip(
                                                label: cat.name,
                                                icon: cat.icon,
                                                imageUrl: cat.image,
                                                isSelected:
                                                    controller.selectedCategoryId == cat.id,
                                                onTap: () => controller.selectCategory(cat.id),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),

                          // --- Markets List ---
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index == sortedMarkets.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final market = sortedMarkets[index];
                                  if (index == 0) {
                                    // First market: wrap in Obx for reactive product updates
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 24.h),
                                      child: Obx(() {
                                        final products = controller.firstMarketProducts;
                                        final productCount = controller.firstMarketProductCount;
                                        final isLoadingProducts = controller.isLoadingFirstMarketProducts;
                                        return MarketCard(
                                          market: market,
                                          productItems: products.isNotEmpty ? products : null,
                                          totalProductCount: productCount,
                                          isLoadingProducts: isLoadingProducts,
                                        );
                                      }),
                                    );
                                  }
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 24.h),
                                    child: MarketCard(market: market),
                                  );
                                },
                                childCount: sortedMarkets.length +
                                    (controller.hasMore ? 1 : 0),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketsShimmerSliver() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Container(
                height: 240.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 0.76,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 20.h,
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  height: 14.h,
                                  width: 160.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            );
          },
          childCount: 4,
        ),
      ),
    );
  }
}

// ─── Market Card ───────────────────────────────────────────────────
class MarketCard extends StatelessWidget {
  final Market market;
  final List<MarketProductItem>? productItems;
  final int totalProductCount;
  final bool isLoadingProducts;

  const MarketCard({
    super.key,
    required this.market,
    this.productItems,
    this.totalProductCount = 0,
    this.isLoadingProducts = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasProducts = productItems != null && productItems!.isNotEmpty;
    final int totalProducts = totalProductCount;

    final bool isOpen = market.isOpen;

    return GestureDetector(
      onTap: () {

        Get.to(() => MarketDetailsPage(marketId: market.id));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
                width: 0.76,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Market Info Row ---
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Market Logo
                      Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFF3F4F6),
                            width: 0.76,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: market.logo != null && market.logo!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: market.logo!,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      _buildLogoPlaceholder(),
                                )
                              : _buildLogoPlaceholder(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Market Name + Rating + Delivery info
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    market.name,
                                    style: const TextStyle().textColorBold(
                                      fontSize: 18,
                                      color: AppColors.textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                // Rating badge
                                _RatingBadge(
                                  rating: market.averageRatingDisplay,
                                ),
                                // Delivery info row
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Open/Closed indicator
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: isOpen ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  isOpen ? 'مفتوح' : 'مغلق',
                                  style: const TextStyle().textColorMedium(
                                    fontSize: 12,
                                    color: isOpen ? Colors.green : Colors.red,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                // Dot separator
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Container(
                                    width: 4.w,
                                    height: 4.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD1D5DC),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // Delivery time
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12.sp,
                                      color: const Color(0xFF99A1AF),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      market.deliveryTime > 0
                                          ? '${market.deliveryTime} د'
                                          : '-- د',
                                      style: const TextStyle().textColorMedium(
                                        fontSize: 12,
                                        color: const Color(0xFF99A1AF),
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ],
                                ),
                                // Dot separator
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Container(
                                    width: 4.w,
                                    height: 4.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD1D5DC),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // Delivery fee
                                Flexible(
                                  child: Text(
                                    market.deliveryFeeDisplay,
                                    style: const TextStyle().textColorMedium(
                                      fontSize: 12,
                                      color: const Color(0xFF99A1AF),
                                    ),
                                    textDirection: TextDirection.rtl,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Featured Products Section ---
            // Text("${isLoadingProducts} - ${hasProducts} - $totalProducts"),
            if (isLoadingProducts) ...[
              SizedBox(height: 20.h),
              _buildProductsShimmer(),
            ] else if (hasProducts || totalProducts > 0) ...[
              SizedBox(height: 20.h),
              Container(
                margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 1.h),
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row: "منتجات مختارة" + "تسوق الآن"
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "منتجات مختارة"
                          Text(
                            'منتجات مختارة',
                            style: const TextStyle().textColorBold(
                              fontSize: 10,
                              color: const Color(0xFF99A1AF),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          // "تسوق الآن" link
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تسوق الآن',
                                style: const TextStyle().textColorBold(
                                  fontSize: 10,
                                  color: AppColors.purple,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12.sp,
                                color: AppColors.purple,
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Products thumbnails row
                    SizedBox(
                      height: 73.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        textDirection: TextDirection.rtl,
                        children: [
                          // Product thumbnails from API
                          if (hasProducts) ...[
                            ...productItems!.take(3).map(
                                  (item) => Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: _ProductItemThumbnail(
                                      productItem: item,
                                    ),
                                  ),
                                ),
                            SizedBox(width: 8.w),
                          ],
                          // "+N" count badge
                          if (totalProducts > 0)
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Stack(
                                children: [
                                  if (market.logo != null)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        child: Opacity(
                                          opacity: 0.2,
                                          child: CachedNetworkImage(
                                            imageUrl: market.logo!,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Text(
                                      '+$totalProducts',
                                      style: const TextStyle().textColorBold(
                                        fontSize: 12,
                                        color: AppColors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              SizedBox(height: 20.h),
          ],
        ),
      ),
      // Closed overlay
      if (!isOpen)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x3A7F22FE),
              borderRadius: BorderRadius.circular(32.r),
            ),
            padding: EdgeInsets.all(10),
            alignment: Alignment.bottomCenter,
            child: Text(
              'مغلق الأن',
              textAlign: TextAlign.center,
              style: const TextStyle().textColorBold(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildProductsShimmer() {
    return ShimmerLoading(
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 1.h),
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shimmer header row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 70.w, height: 12.h, borderRadius: 6),
                  ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Shimmer product thumbnails row
            SizedBox(
              height: 73.h,
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: index < 3 ? 8.w : 0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ShimmerBox(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Icon(
        Icons.store_rounded,
        size: 32.sp,
        color: Colors.grey[400],
      ),
    );
  }
}

// ─── Rating Badge (yellow bg with star) ────────────────────────────
class _RatingBadge extends StatelessWidget {
  final String rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14.sp,
            color: const Color(0xFFFBBF24),
          ),
          SizedBox(width: 4.w),
          Padding(
            padding: const EdgeInsets.only(top:1),
            child: Text(
              rating,
              style: const TextStyle().textColorBold(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Item Thumbnail (from API) ─────────────────────────────
class _ProductItemThumbnail extends StatelessWidget {
  final MarketProductItem productItem;

  const _ProductItemThumbnail({required this.productItem});

  @override
  Widget build(BuildContext context) {
    final imageUrl = productItem.thumbnailUrl;
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 0.76,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    _buildProductPlaceholder(),
              )
            : _buildProductPlaceholder(),
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 24.sp,
        color: Colors.grey[400],
      ),
    );
  }
}

// ─── Market Category Chip ──────────────────────────────────────────
class _MarketCategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _MarketCategoryChip({
    required this.label,
    this.icon,
    this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : const Color(0xFF6A7282);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        constraints: BoxConstraints(minWidth: 88.w, minHeight: 45.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            width: 0.76,
            color: isSelected
                ? AppColors.purple
                : const Color(0xFFE5E5E5),
          ),
          // boxShadow: isSelected
          //     ? [
          //         BoxShadow(
          //           color: const Color(0xFFDDD6FF),
          //           blurRadius: 15,
          //           offset: const Offset(0, 10),
          //         ),
          //         BoxShadow(
          //           color: const Color(0xFFDDD6FF),
          //           blurRadius: 6,
          //           offset: const Offset(0, 4),
          //         ),
          //       ]
          //     : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox(),
                ),
              ),
              SizedBox(width: 6.w),
            ] else if (icon != null && icon!.isNotEmpty) ...[
              Text(
                icon!,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
