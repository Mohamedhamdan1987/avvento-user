import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import 'restaurant_cart_details_page.dart';

class CartListPage extends StatelessWidget {
  const CartListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: CustomAppBar(
        title: 'السلة',
        backgroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.carts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'سلة التسوق فارغة',
                    style: const TextStyle().textColorBold(fontSize: 18.sp),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => controller.refreshCarts(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 29.h),
                  // Header Section
                  _buildHeaderSection(controller.carts.length),
                  SizedBox(height: 33.h),
                  // Cart Cards
                  ...controller.carts.map((cart) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildRestaurantCartCard(context, cart),
                      )),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderSection(int cartCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle().textColorBold(
                  fontSize: 24.sp,
                  color: Color(0xFF101828),
                ),
                children: [
                  const TextSpan(text: 'من أين تريد أن '),
                  TextSpan(
                    text: "\n"+ 'تكمل طلبك اليوم؟',
                    style: const TextStyle().textColorBold(
                      fontSize: 24.sp,
                      color: Color(0xFF7F22FE),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SvgIcon(iconName: "assets/svg/cart/shopping-bag.svg", width: 32.w, height: 32.h),
          ],
        ),
        SizedBox(height: 16.h),
        // Subtitle
        Text(
          'لديك طلبات غير مكتملة في $cartCount ${cartCount == 1 ? 'مطعم' : 'مطاعم'}',
          style: const TextStyle().textColorMedium(
            fontSize: 14.sp,
            color: Color(0xFF6A7282),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCartCard(BuildContext context, RestaurantCartResponse cart) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.restaurantCartDetails, arguments: cart);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 0.761,
          ),
        ),
        child: Column(
          children: [
            // Top Section: Price, Restaurant Info, Logo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Logo (Right in RTL)
                _buildRestaurantLogo(cart.restaurant.logo),
                SizedBox(width: 12.w),
                // Restaurant Info Section (Middle)
                Expanded(
                  child: _buildRestaurantInfoSection(cart),
                ),

                // Price Section (Left in RTL)
                SizedBox(width: 12.w),
                _buildPriceSection(cart.totalPrice),
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
                Expanded(
                  child: _buildCartSummary(cart),
                ),
                SizedBox(width: 12.w),

                // Circular Button
                CustomIconButtonApp(
                  width: 40.w,
                  height: 40.h,
                  radius: 100.r,
                  color: const Color(0xFF101828),
                  onTap: () {
                    Get.to(() => RestaurantCartDetailsPage(cart: cart));
                  },
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
      ),
    );
  }

  Widget _buildPriceSection(double totalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              totalPrice.toStringAsFixed(0),
              style: const TextStyle().textColorBold(
                fontSize: 18.sp,
                color: Color(0xFF7F22FE),
              ),
            ),
            SizedBox(width: 4.w),
            Padding(
              padding: EdgeInsets.only(top: 7.h),
              child: Text(
                'د.ل',
                style: const TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: Color(0xFF7F22FE),
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
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'منذ 20 دقيقة',
            style: const TextStyle().textColorMedium(
              fontSize: 10.sp,
              color: Color(0xFF99A1AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfoSection(RestaurantCartResponse cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant Name
        Text(
          cart.restaurant.name!,
          style: const TextStyle().textColorBold(
            fontSize: 18.sp,
            color: Color(0xFF101828),
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

  Widget _buildRestaurantLogo(String? logoUrl) {
    return Container(
      width: 56.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 0.761,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: logoUrl != null
            ? CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.restaurant,
                  color: Colors.grey,
                ),
              )
            : const Icon(
                Icons.restaurant,
                color: Colors.grey,
              ),
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
              top: BorderSide(
                color: Color(0xFFE5E7EB),
                width: 0.761,
              ),
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

  Widget _buildCartSummary(RestaurantCartResponse cart) {
    final firstItemName = cart.items.isNotEmpty
        ? cart.items.first.item.name
        : '';

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
          firstItemName.isNotEmpty
              ? firstItemName
              : '${cart.items.length} ${cart.items.length == 1 ? 'صنف' : 'أصناف'}',
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
