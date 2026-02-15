import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../../markets/models/market_cart_model.dart';
import 'restaurant_cart_details_page.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';

class CartListPage extends StatelessWidget {
  const CartListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'السلة',
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading) {
            return const CartListShimmer();
          }

          if (controller.allCartsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular icon container
                  Container(
                    width: 160.r,
                    height: 160.r,
                    padding: EdgeInsets.all(16.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F7F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgIcon(
                        iconName: 'assets/svg/cart/shopping-bag.svg',
                        width: 64.r,
                        height: 64.r,
                        color: const Color(0xFFD1D5DB),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Title
                  Text(
                    'السلة فارغة',
                    style: const TextStyle().textColorBold(
                      fontSize: 24.sp,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle
                  Text(
                    'لم تقم بإضافة أي منتجات بعد.',
                    style: const TextStyle().textColorNormal(
                      fontSize: 16.sp,
                      color: const Color(0xFF6A7282),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Browse button
                  CustomButtonApp(
                    text: 'تصفح المتاجر',
                    width: 160.w,
                    height: 48.h,
                    color: const Color(0xFF4D179A),
                    borderRadius: 14.r,
                    textStyle: const TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Get.offAllNamed(AppRoutes.clientNavBar);
                    },
                  ),
                ],
              ),
            );
          }

          return AppRefreshIndicator(
            onRefresh: () async => controller.refreshCarts(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 29.h),
                  // Header Section
                  _buildHeaderSection(context, controller.totalCartCount),
                  SizedBox(height: 33.h),
                  // Restaurant Cart Cards
                  if (controller.carts.isNotEmpty) ...[
                    _buildSectionTitle(context, 'المطاعم', controller.carts.length),
                    SizedBox(height: 12.h),
                    ...controller.carts.map(
                      (cart) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildRestaurantCartCard(context, cart),
                      ),
                    ),
                  ],
                  // Market Cart Cards
                  if (controller.marketCarts.isNotEmpty) ...[
                    if (controller.carts.isNotEmpty) SizedBox(height: 8.h),
                    _buildSectionTitle(context, 'المتاجر', controller.marketCarts.length),
                    SizedBox(height: 12.h),
                    ...controller.marketCarts.map(
                      (cart) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildMarketCartCard(context, cart),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle().textColorBold(
            fontSize: 16.sp,
            color: Theme.of(context).textTheme.titleMedium?.color ?? const Color(0xFF101828),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF7F22FE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: const TextStyle().textColorBold(
              fontSize: 12.sp,
              color: const Color(0xFF7F22FE),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, int cartCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle().textColorBold(
                  fontSize: 24.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                children: [
                  const TextSpan(text: 'من أين تريد أن '),
                  TextSpan(
                    text: "\n" + 'تكمل طلبك اليوم؟',
                    style: TextStyle().textColorBold(
                      fontSize: 24.sp,
                      color: const Color(0xFF7F22FE),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SvgIcon(
              iconName: "assets/svg/cart/shopping-bag.svg",
              width: 32.w,
              height: 32.h,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Subtitle
        Text(
          'لديك طلبات غير مكتملة في $cartCount ${cartCount == 1 ? 'متجر' : 'متاجر'}',
          style: TextStyle().textColorMedium(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  // ─── Restaurant Cart Card ─────────────────────────────────────────
  Widget _buildRestaurantCartCard(
    BuildContext context,
    RestaurantCartResponse cart,
  ) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.restaurantCartDetails, arguments: cart);
      },
      child: _buildCartCardContainer(
        context,
        logoUrl: cart.restaurant.logo,
        name: cart.restaurant.name,
        itemCount: cart.items.length,
        totalPrice: cart.totalPrice,
        fallbackIcon: Icons.restaurant,
        onArrowTap: () {
          Get.to(() => RestaurantCartDetailsPage(cart: cart));
        },
      ),
    );
  }

  // ─── Market Cart Card ─────────────────────────────────────────────
  Widget _buildMarketCartCard(
    BuildContext context,
    MarketCartResponse cart,
  ) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.marketCartDetails, arguments: cart);
      },
      child: _buildCartCardContainer(
        context,
        logoUrl: cart.market.logo,
        name: cart.market.name,
        itemCount: cart.products.length,
        totalPrice: cart.totalPrice,
        fallbackIcon: Icons.store,
        onArrowTap: () {
          Get.toNamed(AppRoutes.marketCartDetails, arguments: cart);
        },
      ),
    );
  }

  // ─── Shared Cart Card Container ───────────────────────────────────
  Widget _buildCartCardContainer(
    BuildContext context, {
    required String? logoUrl,
    required String name,
    required int itemCount,
    required double totalPrice,
    required IconData fallbackIcon,
    required VoidCallback onArrowTap,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.761,
        ),
      ),
      child: Column(
        children: [
          // Top Section: Price, Info, Logo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo (Right in RTL)
              _buildLogo(logoUrl, fallbackIcon),
              SizedBox(width: 12.w),
              // Info Section (Middle)
              Expanded(child: _buildInfoSection(name)),
              // Price Section (Left in RTL)
              SizedBox(width: 12.w),
              _buildPriceSection(context, totalPrice),
            ],
          ),
          SizedBox(height: 16.h),
          // Decorative Divider
          _buildDecorativeDivider(),
          SizedBox(height: 16.h),
          // Bottom Section: Button and Cart Summary
          Row(
            children: [
              // Cart Summary
              Expanded(child: _buildCartSummary(itemCount)),
              SizedBox(width: 12.w),
              // Circular Button
              CustomIconButtonApp(
                width: 40.w,
                height: 40.h,
                radius: 100.r,
                color: const Color(0xFF101828),
                onTap: onArrowTap,
                childWidget: Transform.rotate(
                  angle: 3.14159, // 180 degrees rotation
                  child: SvgIcon(
                    iconName: 'assets/svg/arrow-right.svg',
                    width: 20.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, double totalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              totalPrice.toStringAsFixed(0),
              style: TextStyle().textColorBold(
                fontSize: 18.sp,
                color: const Color(0xFF7F22FE),
              ),
            ),
            SizedBox(width: 4.w),
            Padding(
              padding: EdgeInsets.only(top: 7.h),
              child: Text(
                'د.ل',
                style: TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: const Color(0xFF7F22FE),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        // Time Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'منذ 20 دقيقة',
            style: TextStyle().textColorMedium(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          name,
          style: const TextStyle().textColorBold(
            fontSize: 18.sp,
            color: const Color(0xFF101828),
          ),
        ),
        SizedBox(height: 4.h),
        // Status with Green Dot
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: const Color(0xFF00C950).withOpacity(0.857),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'مفتوح الآن',
              style: const TextStyle().textColorMedium(
                fontSize: 12.sp,
                color: Color(0xFF6A7282),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo(String? logoUrl, IconData fallbackIcon) {
    return Container(
      width: 56.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 0.761),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: logoUrl != null
            ? CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Icon(fallbackIcon, color: Colors.grey),
              )
            : Icon(fallbackIcon, color: Colors.grey),
      ),
    );
  }

  Widget _buildDecorativeDivider() {
    return Stack(
      children: [
        Container(
          height: 0.761,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 0.761),
            ),
          ),
        ),
        // Left Circle
        PositionedDirectional(
          start: -28.w,
          top: -8.h,
          child: Container(
            width: 16.w,
            height: 16.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Right Circle
        PositionedDirectional(
          end: -28.w,
          top: -8.h,
          child: Container(
            width: 16.w,
            height: 16.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartSummary(int itemCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملخص السلة',
          style: const TextStyle().textColorBold(
            fontSize: 12.sp,
            color: Color(0xFF99A1AF),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$itemCount ${itemCount == 1 ? 'صنف' : 'أصناف'}',
          style: const TextStyle().textColorMedium(
            fontSize: 14.sp,
            color: Color(0xFF364153),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
