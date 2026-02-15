import 'dart:math';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/svg_icon.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';
import '../controllers/market_cart_controller.dart';
import '../controllers/market_details_controller.dart';
import '../models/market_product_item.dart';
import '../models/market_cart_model.dart';
import '../services/markets_service.dart';
import 'market_cart_details_page.dart';
import 'market_product_details_dialog.dart';

class _CategoryProductsController extends GetxController {
  final MarketsService _marketsService = MarketsService();
  final String marketId;
  final String categoryId;

  _CategoryProductsController({
    required this.marketId,
    required this.categoryId,
  });

  final RxList<MarketProductItem> products = <MarketProductItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await _marketsService.getMarketProducts(
        marketId,
        page: 1,
        limit: 100,
        categoryId: categoryId,
      );
      products.assignAll(response.products);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}

class MarketCategoryProductsPage extends StatelessWidget {
  final String marketId;
  final String categoryId;
  final String categoryName;
  final String? categoryImage;

  MarketCategoryProductsPage({
    super.key,
    required this.marketId,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  }) {
    Get.put(
      _CategoryProductsController(
        marketId: marketId,
        categoryId: categoryId,
      ),
      tag: categoryId,
    );
  }

  _CategoryProductsController get _ctrl =>
      Get.find<_CategoryProductsController>(tag: categoryId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        final cartController = Get.find<MarketCartController>();
        final cart = cartController.carts.firstWhereOrNull(
          (c) => c.market.id == marketId,
        );
        if (cart == null || cart.products.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildViewCartButton(context, cart);
      }),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 160.h,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              leading: const SizedBox.shrink(),
              leadingWidth: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (categoryImage != null && categoryImage!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: categoryImage!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.purple.withOpacity(0.15),
                        ),
                      )
                    else
                      Container(color: AppColors.purple.withOpacity(0.15)),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
                titlePadding:
                    EdgeInsetsDirectional.only(start: 24.w, bottom: 16.h),
                title: Text(
                  categoryName,
                  style: TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 16.w),
                  child: CustomIconButtonApp(
                    width: 40.w,
                    height: 40.h,
                    radius: 100.r,
                    color: Colors.white.withOpacity(0.2),
                    onTap: () => Navigator.pop(context),
                    childWidget: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18.w,
                    ),
                  ),
                ),
              ],
            ),

            // Products List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              sliver: Obx(() {
                if (_ctrl.isLoading.value && _ctrl.products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _ProductsShimmer(),
                  );
                }

                if (_ctrl.hasError.value && _ctrl.products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline,
                                size: 64.w, color: Colors.red),
                            SizedBox(height: 16.h),
                            Text(
                              'فشل تحميل المنتجات',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _ctrl.fetchProducts,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (_ctrl.products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64.w,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد منتجات في هذا القسم',
                              style: TextStyle().textColorMedium(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(
                      context,
                      _ctrl.products[index],
                    ),
                    childCount: _ctrl.products.length,
                  ),
                );
              }),
            ),

            // Bottom spacing for FAB
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, MarketProductItem product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarketProductDetailsDialog(
        product: product,
        marketId: marketId,
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, MarketProductItem product) {
    final cartController = Get.find<MarketCartController>();
    final quantity =
        cartController.getProductQuantityInCart(marketId, product.id);

    final imageUrl = product.thumbnailUrl;

    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
              color: Theme.of(context).dividerColor, width: 0.76.w),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 96.w,
                  height: 96.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 96.w,
                          height: 96.h,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.shopping_bag_outlined,
                          size: 40.w, color: Colors.grey),
                ),
              ),
              SizedBox(width: 12.w),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.product.name,
                            style: TextStyle().textColorBold(
                              fontSize: 16.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        quantity > 0
                            ? Container(
                                height: 28.h,
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF101828),
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: cartController
                                              .isProductUpdating(product.id)
                                          ? null
                                          : () => _updateQuantity(
                                              context, product, quantity - 1),
                                      child: AnimatedOpacity(
                                        opacity: cartController
                                                .isProductUpdating(product.id)
                                            ? 0.4
                                            : 1.0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Icon(Icons.remove,
                                            color: Colors.white, size: 16.w),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    SizedBox(
                                      width: 18.w,
                                      height: 18.h,
                                      child: Center(
                                        child: cartController
                                                .isProductUpdating(product.id)
                                            ? SizedBox(
                                                width: 14.w,
                                                height: 14.h,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                '$quantity',
                                                style:
                                                    TextStyle().textColorBold(
                                                        fontSize: 14.sp,
                                                        color: Colors.white),
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    GestureDetector(
                                      onTap: cartController
                                              .isProductUpdating(product.id)
                                          ? null
                                          : () => _updateQuantity(
                                              context, product, quantity + 1),
                                      child: AnimatedOpacity(
                                        opacity: cartController
                                                .isProductUpdating(product.id)
                                            ? 0.4
                                            : 1.0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Icon(Icons.add,
                                            color: Colors.white, size: 16.w),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : CustomIconButtonApp(
                                width: 32.w,
                                height: 32.h,
                                radius: 100.r,
                                color: const Color(0xFF101828),
                                onTap: () {
                                  final detailsCtrl =
                                      Get.find<MarketDetailsController>();
                                  detailsCtrl.addToCart(
                                    marketProductId: product.id,
                                    quantity: 1,
                                  );
                                },
                                childWidget: SvgIcon(
                                  iconName: 'assets/svg/plus-solid.svg',
                                  width: 16.w,
                                  height: 16.h,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                    Text(
                      product.product.description,
                      style: TextStyle().textColorNormal(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!product.isAvailable)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'غير متوفر',
                              style: TextStyle().textColorBold(
                                fontSize: 10.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          product.price.toStringAsFixed(0),
                          style: TextStyle().textColorBold(
                            fontSize: 18.sp,
                            color: AppColors.purple,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'د.ل',
                          style: TextStyle().textColorNormal(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color,
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
      ),
    );
  }

  Widget _buildViewCartButton(BuildContext context, MarketCartResponse cart) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: GestureDetector(
          onTap: () {
            Get.to(() => MarketCartDetailsPage(cart: cart));
          },
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFF101828),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.761,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF99A1AF).withOpacity(0.3),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 10.w, end: 24.w),
              child: Row(
                children: [
                  Container(
                    width: 37.r,
                    height: 37.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${cart.products.length}',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: const Color(0xFF101828),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سلة المشتريات',
                        style: TextStyle().textColorBold(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${cart.totalPrice.toStringAsFixed(2)} د.ل',
                        style: TextStyle().textColorMedium(
                          fontSize: 10.sp,
                          color: const Color(0xFF99A1AF),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => MarketCartDetailsPage(cart: cart));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'إتمام الطلب',
                            style: TextStyle().textColorBold(
                              fontSize: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Transform.rotate(
                            angle: pi,
                            child: SvgIcon(
                              iconName: 'assets/svg/arrow-right.svg',
                              width: 16.w,
                              height: 16.h,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateQuantity(
      BuildContext context, MarketProductItem product, int newQuantity) async {
    final cartController = Get.find<MarketCartController>();
    if (cartController.isProductUpdating(product.id)) return;

    cartController.setProductUpdating(product.id);
    try {
      final productIndex =
          cartController.getProductIndexInCart(marketId, product.id);

      if (newQuantity == 0) {
        if (productIndex != -1) {
          await cartController.removeProduct(marketId, productIndex);
        }
      } else {
        if (productIndex != -1) {
          await cartController.updateQuantity(
            marketId: marketId,
            productIndex: productIndex,
            quantity: newQuantity,
          );
        } else {
          final detailsCtrl = Get.find<MarketDetailsController>();
          await detailsCtrl.addToCart(
            marketProductId: product.id,
            quantity: newQuantity,
          );
        }
      }
    } finally {
      cartController.clearProductUpdating(product.id);
    }
  }
}

class _ProductsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ShimmerBox(
                width: double.infinity,
                height: 120.h,
                borderRadius: 24),
          ),
        ),
      ),
    );
  }
}
