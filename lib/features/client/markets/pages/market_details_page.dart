import 'dart:math';
import 'dart:ui';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/location_utils.dart';
import '../../address/controllers/address_controller.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/svg_icon.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';
import '../controllers/market_details_controller.dart';
import '../controllers/market_cart_controller.dart';
import '../models/market_model.dart';
import '../models/market_product_item.dart';
import '../models/market_cart_model.dart';
import 'market_cart_details_page.dart';
import 'market_category_products_page.dart';
import 'market_product_details_dialog.dart';

class MarketDetailsPage extends StatelessWidget {
  final String marketId;

  MarketDetailsPage({super.key, required this.marketId}) {
    if (!Get.isRegistered<MarketCartController>()) {
      Get.put(MarketCartController());
    } else {
      Future.microtask(() => Get.find<MarketCartController>().fetchAllCarts());
    }
    Get.delete<MarketDetailsController>();
    Get.put(MarketDetailsController(marketId: marketId));
  }

  MarketDetailsController get controller =>
      Get.find<MarketDetailsController>();

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
        child: Obx(() {
          if (controller.isLoadingMarketDetails && controller.market == null) {
            return const _MarketDetailsShimmer();
          }

          if (controller.hasError && controller.market == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.w, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      controller.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: controller.getMarketDetails,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.market == null) {
            return const Center(child: Text('المتجر غير موجود'));
          }

          return CustomScrollView(
            slivers: [
              // Shrinking Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _MarketHeaderDelegate(
                  market: controller.market!,
                  onBack: () => Navigator.pop(context),
                  onFavorite: () => controller.toggleFavorite(),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),

                    // Open/Closed Status
                    _buildOpenClosedStatus(context),

                    SizedBox(height: 14.h),

                    // Market Stats Row
                    _buildStatsRow(context),

                    SizedBox(height: 14.h),

                    // Category Chips
                    _buildCategoryChips(context),

                    SizedBox(height: 24.h),

                    // All Products Section
                    _buildAllProductsSection(context),

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOpenClosedStatus(BuildContext context) {
    return InkWell(
      onTap: () => _showOpeningHoursSheet(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final isOpen = controller.market?.isOpen ?? false;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isOpen ? Colors.green : Colors.red)
                                  .withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isOpen ? 'مفتوح الآن' : 'مغلق حالياً',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 4.h),
                Obx(() {
                  final status = controller.schedule?.currentDayStatus;
                  if (status == null) return const SizedBox.shrink();

                  final nextTime = status.isCurrentlyOpen
                      ? status.closeTime
                      : status.openTime;
                  final text = status.isCurrentlyOpen
                      ? 'يغلق الساعة $nextTime'
                      : 'يفتح الساعة $nextTime';

                  return Text(
                    text,
                    style: TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  );
                }),
              ],
            ),
            Row(
              children: [
                Text(
                  'مواعيد العمل',
                  style: TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: AppColors.purple,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20.w,
                  color: AppColors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOpeningHoursSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsetsDirectional.only(
              top: 16.w, start: 16.w, bottom: 24.w, end: 8.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgIcon(
                      iconName:
                          'assets/svg/client/restaurant_details/clock.svg',
                      width: 24.w,
                      height: 24.h,
                      color: AppColors.purple,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواعيد العمل',
                          style: TextStyle().textColorBold(
                            fontSize: 18.sp,
                            color: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.color,
                          ),
                        ),
                        Text(
                          controller.market?.name ?? '',
                          style: TextStyle().textColorMedium(
                            fontSize: 14.sp,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Days List
              Obx(() {
                if (controller.isLoadingSchedule) {
                  return ShimmerLoading(
                    child: Column(
                      children: List.generate(
                        7,
                        (_) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                ShimmerBox(
                                    width: 60.w,
                                    height: 14.h,
                                    borderRadius: 6),
                                ShimmerBox(
                                    width: 100.w,
                                    height: 14.h,
                                    borderRadius: 6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final schedule = controller.schedule;
                if (schedule == null) {
                  return const Center(child: Text('لا توجد بيانات مواعيد'));
                }

                final daysArabic = {
                  'sunday': 'الأحد',
                  'monday': 'الاثنين',
                  'tuesday': 'الثلاثاء',
                  'wednesday': 'الأربعاء',
                  'thursday': 'الخميس',
                  'friday': 'الجمعة',
                  'saturday': 'السبت',
                };

                return Column(
                  children: schedule.weeklySchedule.map((s) {
                    final isCurrent = s.day.toLowerCase() ==
                        schedule.currentDayStatus.day.toLowerCase();
                    final hoursText = s.isClosed
                        ? 'مغلق'
                        : '${s.openTime} - ${s.closeTime}';
                    return _buildDayRow(context,
                        daysArabic[s.day.toLowerCase()] ?? s.day, hoursText,
                        isCurrent: isCurrent);
                  }).toList(),
                );
              }),

              SizedBox(height: 32.h),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String day, String hours,
      {bool isCurrent = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.purple.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isCurrent
            ? Border.all(color: AppColors.purple.withOpacity(0.2))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle().textColorMedium(
              fontSize: 14.sp,
              color: isCurrent
                  ? AppColors.purple
                  : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          Text(
            hours,
            style: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: isCurrent
                  ? AppColors.purple
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
      decoration: ShapeDecoration(
        color: const Color(0x11D9D9D9),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x33E3E3E3),
          ),
          borderRadius: BorderRadius.circular(21),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/clock.svg',
            value: controller.market!.deliveryTime > 0
                ? '${controller.market!.deliveryTime} دقيقة'
                : '-- دقيقة',
            label: 'التوصيل',
          ),
          Container(width: 1.w, height: 32.h, color: const Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/bike.svg',
            value: controller.market!.deliveryFeeDisplay,
            label: 'رسوم التوصيل',
          ),
          Container(width: 1.w, height: 32.h, color: const Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/inactive_star_icon.svg',
            value: controller.market!.averageRatingDisplay,
            label: 'التقييم',
          ),
          Container(width: 1.w, height: 32.h, color: const Color(0xFFF3F4F6)),
          Builder(
            builder: (context) {
              final addressController = Get.find<AddressController>();
              String distanceText = '--';

              // Prefer selected address as the user's location
              final activeAddress = addressController.activeAddress.value;
              if (activeAddress != null) {
                final distance = LocationUtils.calculateDistance(
                  userLat: activeAddress.lat,
                  userLong: activeAddress.long,
                  restaurantLat: controller.market!.lat,
                  restaurantLong: controller.market!.long,
                );
                distanceText = LocationUtils.formatDistance(distance);
              } else if (LocationUtils.isInitialized &&
                  LocationUtils.currentLatitude != null &&
                  LocationUtils.currentLongitude != null) {
                // Fallback to device location if no active address
                final distance = LocationUtils.calculateDistance(
                  restaurantLat: controller.market!.lat,
                  restaurantLong: controller.market!.long,
                );
                distanceText = LocationUtils.formatDistance(distance);
              }

              return _buildStatItem(
                context,
                icon: 'assets/svg/client/restaurant_details/clock.svg',
                value: distanceText,
                label: 'المسافة',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        SvgIcon(
          iconName: icon,
          width: 16.w,
          height: 16.h,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: const TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: const TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCategories && controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }
      if (controller.categories.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 48.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            ...controller.categories.map(
              (cat) => Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: _CategoryChip(
                  label: cat.name,
                  imageUrl: cat.image,
                  isSelected: false,
                  onTap: () => Get.to(() => MarketCategoryProductsPage(
                        marketId: marketId,
                        categoryId: cat.id,
                        categoryName: cat.name,
                        categoryImage: cat.image,
                      )),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAllProductsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.w,
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              Text(
                'جميع المنتجات',
                style: const TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (controller.isLoadingProducts && controller.products.isEmpty) {
              return const _ProductsShimmer();
            }
            if (controller.products.isEmpty) {
              return const Center(child: Text('لا توجد منتجات'));
            }

            // Group products by category
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < controller.products.length; i++) ...[
                  if (i == 0 ||
                      controller.products[i].product.category?.id !=
                          controller.products[i - 1].product.category?.id)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: 16.h, bottom: 8.h),
                      child: Text(
                        controller.products[i].product.category?.name ??
                            'منتجات',
                        style: const TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  _buildProductCard(context, controller.products[i]),
                ],
              ],
            );
          }),
        ],
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
                                    onTap: cartController.isProductUpdating(product.id)
                                        ? null
                                        : () => _updateQuantity(
                                            context, product, quantity - 1),
                                    child: AnimatedOpacity(
                                      opacity: cartController.isProductUpdating(product.id) ? 0.4 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(Icons.remove,
                                          color: Colors.white, size: 16.w),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  SizedBox(
                                    width: 18.w,
                                    height: 18.h,
                                    child: Center(
                                      child: cartController.isProductUpdating(product.id)
                                          ? SizedBox(
                                              width: 14.w,
                                              height: 14.h,
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              '$quantity',
                                              style: TextStyle().textColorBold(
                                                  fontSize: 14.sp,
                                                  color: Colors.white),
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: cartController.isProductUpdating(product.id)
                                        ? null
                                        : () => _updateQuantity(
                                            context, product, quantity + 1),
                                    child: AnimatedOpacity(
                                      opacity: cartController.isProductUpdating(product.id) ? 0.4 : 1.0,
                                      duration: const Duration(milliseconds: 200),
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
                                controller.addToCart(
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
          await controller.addToCart(
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

// ─── Market Header Delegate ─────────────────────────────────────────
class _MarketHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Market market;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  _MarketHeaderDelegate({
    required this.market,
    required this.onBack,
    required this.onFavorite,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = shrinkOffset / maxExtent;
    final double avatarSize = 100.w * (1 - progress).clamp(0.6, 1.0);
    final double titleOpacity = (progress * 2).clamp(0, 1);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Background Image with Blur
        ClipRRect(
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(30.r),
          ),
          child: Stack(
            children: [
              if (market.backgroundImage != null &&
                  market.backgroundImage!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: market.backgroundImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Container(color: AppColors.purple.withOpacity(0.3)),
                )
              else
                Container(color: AppColors.purple.withOpacity(0.3)),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: progress * 10,
                  sigmaY: progress * 10,
                ),
                child: Container(
                  color: Colors.black.withOpacity(progress * 0.4),
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButtonApp(
                onTap: onBack,
                color: Colors.white.withOpacity(0.2),
                childWidget: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
              Opacity(
                opacity: titleOpacity,
                child: Text(
                  market.name,
                  style: TextStyle().textColorBold(
                      fontSize: 18.sp, color: Colors.white),
                ),
              ),
              Obx(() {
                final ctrl = Get.find<MarketDetailsController>();
                final isFav = ctrl.isFavorite;
                return CustomIconButtonApp(
                  onTap: onFavorite,
                  color: Colors.white.withOpacity(0.2),
                  childWidget: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.white,
                    size: 20,
                  ),
                );
              }),
            ],
          ),
        ),

        // Profile Picture (Avatar)
        PositionedDirectional(
          top: lerpDouble(
              200.h,
              MediaQuery.of(context).padding.top + 10.h,
              progress + 0.05)!,
          end: 24.w,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: (market.logo != null && market.logo!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: market.logo!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey[300]),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.store,
                          size: 40.w, color: Colors.grey)),
            ),
          ),
        ),

        // Name & Info (Bottom of header)
        if (progress < 0.8)
          PositionedDirectional(
            bottom: 20.h,
            start: 24.w,
            child: Opacity(
              opacity: (1 - progress * 2).clamp(0, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    market.name,
                    style: TextStyle().textColorBold(
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    market.description.isNotEmpty
                        ? market.description
                        : market.address,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  double get maxExtent => 250.h;

  @override
  double get minExtent => 100.h + Get.mediaQuery.padding.top;

  @override
  bool shouldRebuild(covariant _MarketHeaderDelegate oldDelegate) => true;
}

// ─── Category Chip ──────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
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
          color: isSelected ? AppColors.purple : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            width: 0.76,
            color: isSelected ? AppColors.purple : const Color(0xFFE5E5E5),
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0xFFDDD6FF),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
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

// ─── Shimmer Widgets ────────────────────────────────────────────────
class _MarketDetailsShimmer extends StatelessWidget {
  const _MarketDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(height: 250.h, color: Colors.grey[300]),
            SizedBox(height: 60.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  ShimmerBox(
                      width: double.infinity,
                      height: 60.h,
                      borderRadius: 21),
                  SizedBox(height: 24.h),
                  ShimmerBox(
                      width: double.infinity,
                      height: 48.h,
                      borderRadius: 16),
                  SizedBox(height: 24.h),
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: ShimmerBox(
                          width: double.infinity,
                          height: 120.h,
                          borderRadius: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsShimmer extends StatelessWidget {
  const _ProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: List.generate(
          3,
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
