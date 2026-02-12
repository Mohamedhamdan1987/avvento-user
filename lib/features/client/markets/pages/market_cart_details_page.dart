import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';
import '../controllers/market_cart_controller.dart';
import '../models/market_cart_model.dart';
import 'market_details_page.dart';
import 'market_checkout_page.dart';

class MarketCartDetailsPage extends StatefulWidget {
  final MarketCartResponse cart;
  const MarketCartDetailsPage({super.key, required this.cart});

  @override
  State<MarketCartDetailsPage> createState() => _MarketCartDetailsPageState();
}

class _MarketCartDetailsPageState extends State<MarketCartDetailsPage> {
  final MarketCartController controller = Get.find<MarketCartController>();
  bool _isInvoiceExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMarketCart(widget.cart.market.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'السلة',
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        actions: [
          CustomIconButtonApp(
            onTap: () {
              AppDialogs.showDeleteConfirmation(
                title: 'مسح السلة',
                description:
                    'هل أنت متأكد من مسح جميع المنتجات من السلة؟',
                confirmText: 'مسح',
                onConfirm: () async {
                  await controller.clearCart(widget.cart.market.id);
                },
              );
            },
            childWidget: Icon(
              Icons.delete_sweep_outlined,
              color: Colors.red,
              size: 24.r,
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading && controller.detailedCart == null) {
            return const _CartDetailsShimmer();
          }

          final currentCart = controller.detailedCart;
          if (currentCart == null) {
            return const Center(child: Text('فشل تحميل البيانات'));
          }

          if (currentCart.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 80.r,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'السلة فارغة',
                    style:
                        const TextStyle().textColorBold(fontSize: 18.sp),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 13.h),
                      // Market Info Header
                      _buildMarketHeader(currentCart),
                      SizedBox(height: 13.h),
                      // Cart Products
                      ...currentCart.products.map(
                        (product) => Padding(
                          padding: EdgeInsets.only(bottom: 13.h),
                          child: _buildCartProductCard(
                            product,
                            currentCart.products.indexOf(product),
                            currentCart,
                          ),
                        ),
                      ),
                      SizedBox(height: 13.h),
                      // Add Items Button
                      _buildAddItemsButton(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              _buildBottomSummary(currentCart),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMarketHeader(MarketCartResponse currentCart) {
    return InkWell(
      onTap: () {
        Get.to(
          () => MarketDetailsPage(marketId: widget.cart.market.id),
        )?.then((value) {
          controller.fetchMarketCart(widget.cart.market.id);
        });
      },
      child: Container(
        padding:
            EdgeInsetsDirectional.only(start: 16.76.w, top: 1, bottom: 1),
        height: 73.51.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.761,
          ),
        ),
        child: Row(
          children: [
            // Market Logo
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.761,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: currentCart.market.logo != null
                    ? CachedNetworkImage(
                        imageUrl: currentCart.market.logo!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.store, color: Colors.grey),
              ),
            ),
            SizedBox(width: 12.w),
            // Market Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentCart.market.name,
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color:
                          Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  if (currentCart.market.address != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      currentCart.market.address!,
                      style: TextStyle().textColorNormal(
                        fontSize: 12.sp,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            CustomIconButtonApp(
              onTap: () => Navigator.pop(context),
              childWidget: Transform.rotate(
                angle: 3.14159,
                child: SvgIcon(
                  iconName: 'assets/svg/arrow-right.svg',
                  width: 16.w,
                  height: 16.h,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartProductCard(
    MarketCartProduct cartProduct,
    int index,
    MarketCartResponse currentCart,
  ) {
    final productImage = cartProduct.marketProduct.thumbnailUrl;

    return Container(
      height: 125.49.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: Theme.of(context).dividerColor, width: 0.761),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Padding(
                padding: EdgeInsetsDirectional.only(
                    top: 22.h, end: 16.w, start: 16.w),
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: productImage != null
                        ? CachedNetworkImage(
                            imageUrl: productImage,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[200]),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Product Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartProduct.marketProduct.product.name,
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${cartProduct.totalPrice.toStringAsFixed(0)} د.ل',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color,
                        ),
                      ),
                      if (cartProduct.notes.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          cartProduct.notes,
                          style: TextStyle().textColorNormal(
                            fontSize: 11.sp,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      // Quantity controls
                      Obx(() {
                        if (controller.updatingProductIndex == index) {
                          return SizedBox(
                            width: 120.w,
                            height: 36.h,
                            child: Center(
                              child: SizedBox(
                                width: 16.r,
                                height: 16.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF7F22FE),
                                ),
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: 100.w,
                          height: 36.h,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.761,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              // Plus Button
                              GestureDetector(
                                onTap: () {
                                  controller.updateQuantity(
                                    marketId: currentCart.market.id,
                                    productIndex: index,
                                    quantity: cartProduct.quantity + 1,
                                    notes: cartProduct.notes,
                                  );
                                },
                                child: Container(
                                  height: 34.48.h,
                                  alignment: Alignment.center,
                                  child: SvgIcon(
                                    iconName:
                                        'assets/svg/client/restaurant_details/plus_icon.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    color:
                                        Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),
                              Text(
                                '${cartProduct.quantity}',
                                style: TextStyle().textColorBold(
                                  fontSize: 14.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              // Minus Button
                              GestureDetector(
                                onTap: () {
                                  if (cartProduct.quantity > 1) {
                                    controller.updateQuantity(
                                      marketId: currentCart.market.id,
                                      productIndex: index,
                                      quantity: cartProduct.quantity - 1,
                                      notes: cartProduct.notes,
                                    );
                                  } else {
                                    AppDialogs.showDeleteConfirmation(
                                      title: 'حذف المنتج',
                                      description:
                                          'هل أنت متأكد من حذف هذا المنتج من السلة؟',
                                      onConfirm: () async {
                                        await controller.removeProduct(
                                          currentCart.market.id,
                                          index,
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  height: 34.48.h,
                                  alignment: Alignment.center,
                                  child: SvgIcon(
                                    iconName: cartProduct.quantity > 1
                                        ? 'assets/svg/client/restaurant_details/minus_icon.svg'
                                        : 'assets/svg/cart/delete.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    color:
                                        Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Delete Button
              Padding(
                padding: EdgeInsetsDirectional.only(top: 16.h, end: 16.w),
                child: GestureDetector(
                  onTap: () {
                    AppDialogs.showDeleteConfirmation(
                      title: 'حذف المنتج',
                      description:
                          'هل أنت متأكد من حذف هذا المنتج من السلة؟',
                      onConfirm: () async {
                        await controller.removeProduct(
                          currentCart.market.id,
                          index,
                        );
                      },
                    );
                  },
                  child: SvgIcon(
                    iconName: 'assets/svg/cart/delete.svg',
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemsButton() {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => MarketDetailsPage(marketId: widget.cart.market.id),
        )?.then((value) {
          controller.fetchMarketCart(widget.cart.market.id);
        });
      },
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: const Color(0xFF7F22FE).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              iconName:
                  'assets/svg/client/restaurant_details/plus_icon.svg',
              width: 16.w,
              height: 16.h,
              color: const Color(0xFF7F22FE),
            ),
            SizedBox(width: 8.w),
            Text(
              'إضافة منتجات',
              style: const TextStyle().textColorBold(
                fontSize: 14.sp,
                color: const Color(0xFF7F22FE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(MarketCartResponse currentCart) {
    return Container(
      padding: EdgeInsets.only(
        top: 16.h,
        left: 24.w,
        right: 24.w,
        bottom: 24.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border(
          top: BorderSide(
              color: Theme.of(context).dividerColor, width: 0.761),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Invoice Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isInvoiceExpanded = !_isInvoiceExpanded;
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButtonApp(
                    onTap: () {
                      setState(() {
                        _isInvoiceExpanded = !_isInvoiceExpanded;
                      });
                    },
                    childWidget: Transform.rotate(
                      angle: _isInvoiceExpanded ? 3.14159 : 0,
                      child: SvgIcon(
                        iconName: 'assets/svg/cart/arrow-top.svg',
                        width: 20.w,
                        height: 20.h,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  Text(
                    'الفاتورة',
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color:
                          Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Checkout Button
          Obx(
            () => GestureDetector(
              onTap: controller.isLoading
                  ? null
                  : () {
                      Get.to(() => MarketCheckoutPage(cart: currentCart));
                    },
              child: Container(
                height: 56.h,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D179A),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF8E51FF).withOpacity(0.19),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (controller.isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white),
                      )
                    else
                      Text(
                        'تأكيد الطلب',
                        style: TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    if (!controller.isLoading)
                      Text(
                        '${currentCart.totalPrice.toStringAsFixed(0)} د.ل',
                        style: TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Invoice Details (Expandable)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                SizedBox(height: 16.h),
                _buildInvoiceRow(
                  'المجموع الفرعي',
                  '${currentCart.totalPrice.toStringAsFixed(0)} د.ل',
                ),
                SizedBox(height: 12.h),
                _buildInvoiceRow(
                  'رسوم التوصيل',
                  'يحسب عند الدفع',
                ),
                SizedBox(height: 12.h),
                const Divider(height: 1),
                SizedBox(height: 12.h),
                _buildInvoiceRow(
                  'المجموع الكلي',
                  '${currentCart.totalPrice.toStringAsFixed(0)} د.ل',
                  isTotal: true,
                ),
                SizedBox(height: 8.h),
              ],
            ),
            crossFadeState: _isInvoiceExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String title, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color,
                )
              : TextStyle().textColorNormal(
                  fontSize: 14.sp,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: Theme.of(context).primaryColor,
                )
              : TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color,
                ),
        ),
      ],
    );
  }
}

// ─── Shimmer Widget ─────────────────────────────────────────────────
class _CartDetailsShimmer extends StatelessWidget {
  const _CartDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            ShimmerBox(
                width: double.infinity, height: 73.h, borderRadius: 16),
            SizedBox(height: 16.h),
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 13.h),
                child: ShimmerBox(
                    width: double.infinity,
                    height: 125.h,
                    borderRadius: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
