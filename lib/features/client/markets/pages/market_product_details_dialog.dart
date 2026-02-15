import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/market_details_controller.dart';
import '../controllers/market_cart_controller.dart';
import '../models/market_product_item.dart';

class MarketProductDetailsDialog extends StatefulWidget {
  final MarketProductItem product;
  final String marketId;

  const MarketProductDetailsDialog({
    super.key,
    required this.product,
    required this.marketId,
  });

  @override
  State<MarketProductDetailsDialog> createState() =>
      _MarketProductDetailsDialogState();
}

class _MarketProductDetailsDialogState
    extends State<MarketProductDetailsDialog> {
  int quantity = 1;
  final TextEditingController notesController = TextEditingController();
  bool _isUpdatingQuantity = false;

  @override
  void initState() {
    super.initState();
    // Check if product is already in cart and set initial quantity
    final cartController = Get.find<MarketCartController>();
    final cartQuantity = cartController.getProductQuantityInCart(
      widget.marketId,
      widget.product.id,
    );
    if (cartQuantity > 0) {
      quantity = cartQuantity;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  double get totalPrice => widget.product.price * quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Image Section
            _buildHeaderImage(context),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Info Section
                    _buildProductInfoSection(),

                    SizedBox(height: 16.h),

                    // Product Details (Brand, Unit, etc.)
                    if (_hasProductDetails()) ...[
                      _buildProductDetailsSection(),
                      SizedBox(height: 16.h),
                    ],

                    // Notes Section
                    _buildNotesSection(),

                    SizedBox(height: 16.h),

                    SizedBox(height: 100.h), // Space for bottom bar
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  bool _hasProductDetails() {
    return widget.product.product.brand != null ||
        widget.product.product.unit != null;
  }

  Widget _buildHeaderImage(BuildContext context) {
    final imageUrl = widget.product.thumbnailUrl;
    final allImages = widget.product.product.images;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Image
        SizedBox(
          height: 290.h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.r),
              topRight: Radius.circular(40.r),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Dismiss by tapping background
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              // Interactive Viewer for zooming
                              InteractiveViewer(
                                panEnabled: true,
                                boundaryMargin: const EdgeInsets.all(20),
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                ),
                              ),
                              // Close Button
                              Positioned(
                                top: 40.h,
                                right: 20.w,
                                child: CustomIconButtonApp(
                                  width: 40.w,
                                  height: 40.h,
                                  radius: 100.r,
                                  color: Colors.white.withOpacity(0.2),
                                  borderColor: Colors.white.withOpacity(0.2),
                                  onTap: () => Navigator.pop(context),
                                  childWidget: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 24.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 290.h,
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 80.w,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),

        // Gradient Overlay
        IgnorePointer(
          ignoring: true,
          child: Container(
            height: 290.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.r),
                topRight: Radius.circular(40.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).cardColor.withOpacity(0.2),
                  Theme.of(context).cardColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Close Button
        Positioned(
          top: 24.h,
          right: 24.w,
          child: CustomIconButtonApp(
            width: 40.w,
            height: 40.h,
            radius: 100.r,
            color: Colors.white.withOpacity(0.2),
            borderColor: Colors.white.withOpacity(0.2),
            onTap: () {
              Navigator.pop(context);
            },
            childWidget: SvgIcon(
              iconName: 'assets/svg/arrow-right.svg',
              width: 20.w,
              height: 20.h,
              color: Colors.white,
            ),
          ),
        ),

        // Image count indicator (if multiple images)
        if (allImages.length > 1)
          Positioned(
            top: 24.h,
            left: 24.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 16.w,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${allImages.length}',
                    style: const TextStyle().textColorBold(
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.product.name,
                      style: const TextStyle().textColorBold(
                        fontSize: 25.sp,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    if (widget.product.product.description.isNotEmpty)
                      Text(
                        widget.product.product.description,
                        style: const TextStyle().textColorMedium(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.product.price.toStringAsFixed(0),
                        style: const TextStyle().textColorBold(
                          fontSize: 24.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          'د.ل',
                          style: const TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Availability & Category tags
          Row(
            children: [
              if (!widget.product.isAvailable)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        size: 14.w,
                        color: Colors.red,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'غير متوفر',
                        style: const TextStyle().textColorBold(
                          fontSize: 12.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.product.isAvailable)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14.w,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'متوفر',
                        style: const TextStyle().textColorBold(
                          fontSize: 12.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.product.product.category != null) ...[
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    widget.product.product.category!.name,
                    style: const TextStyle().textColorBold(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                iconName:
                    'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل المنتج',
                style: const TextStyle().textColorBold(
                  fontSize: 15.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              if (widget.product.product.brand != null &&
                  widget.product.product.brand!.isNotEmpty)
                _buildDetailChip(
                  icon: Icons.business,
                  label: 'العلامة التجارية',
                  value: widget.product.product.brand!,
                ),
              if (widget.product.product.unit != null &&
                  widget.product.product.unit!.isNotEmpty)
                _buildDetailChip(
                  icon: Icons.straighten,
                  label: 'الوحدة',
                  value: widget.product.product.unit!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        border: Border.all(
          color: const Color(0xFF8E51FF).withOpacity(0.2),
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: const Color(0xFF7F22FE)),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle().textColorBold(
                  fontSize: 10.sp,
                  color: const Color(0xFF99A1AF),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: const TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                iconName:
                    'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Text(
                'ملاحظات',
                style: const TextStyle().textColorBold(
                  fontSize: 15.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ??
                  const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'ملاحظات على الطلب',
                hintStyle: const TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 18.h,
                ),
              ),
              style: const TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Obx(() {
      final cartController = Get.find<MarketCartController>();
      final controller = Get.find<MarketDetailsController>();
      final isLoading = controller.isAddingToCart;
      final cartQuantity = cartController.getProductQuantityInCart(
        widget.marketId,
        widget.product.id,
      );
      final isInCart = cartQuantity > 0;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: isInCart
            ? _buildUpdateQuantityBar(cartController, controller, isLoading,
                cartQuantity)
            : _buildAddToCartBar(controller, isLoading),
      );
    });
  }

  Future<void> _onDecreaseQuantity(
    MarketCartController cartController,
    MarketDetailsController controller,
    int cartQuantity,
    int productIndex,
  ) async {
    if (_isUpdatingQuantity) return;
    setState(() => _isUpdatingQuantity = true);
    try {
      if (cartQuantity > 1) {
        await cartController.updateQuantity(
          marketId: widget.marketId,
          productIndex: productIndex,
          quantity: cartQuantity - 1,
        );
        setState(() {
          quantity = cartQuantity - 1;
        });
      } else {
        await cartController.removeProduct(widget.marketId, productIndex);
        setState(() {
          quantity = 1;
        });
      }
    } finally {
      if (mounted) setState(() => _isUpdatingQuantity = false);
    }
  }

  Future<void> _onIncreaseQuantity(
    MarketCartController cartController,
    MarketDetailsController controller,
    int cartQuantity,
    int productIndex,
  ) async {
    if (_isUpdatingQuantity) return;
    setState(() => _isUpdatingQuantity = true);
    try {
      await cartController.updateQuantity(
        marketId: widget.marketId,
        productIndex: productIndex,
        quantity: cartQuantity + 1,
      );
      setState(() {
        quantity = cartQuantity + 1;
      });
    } finally {
      if (mounted) setState(() => _isUpdatingQuantity = false);
    }
  }

  Widget _buildUpdateQuantityBar(
    MarketCartController cartController,
    MarketDetailsController controller,
    bool isLoading,
    int cartQuantity,
  ) {
    final productIndex = cartController.getProductIndexInCart(
      widget.marketId,
      widget.product.id,
    );
    final isDisabled = _isUpdatingQuantity || isLoading;

    return Row(
      children: [
        // Quantity Selector (dark style)
        Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF101828),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: isDisabled
                    ? null
                    : () => _onDecreaseQuantity(
                          cartController,
                          controller,
                          cartQuantity,
                          productIndex,
                        ),
                child: AnimatedOpacity(
                  opacity: isDisabled ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    alignment: Alignment.center,
                    child: Icon(
                      cartQuantity > 1
                          ? Icons.remove
                          : Icons.delete_outline,
                      color: Colors.white,
                      size: 18.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isUpdatingQuantity
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '$cartQuantity',
                            key: ValueKey(cartQuantity),
                            style: const TextStyle().textColorBold(
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: isDisabled
                    ? null
                    : () => _onIncreaseQuantity(
                          cartController,
                          controller,
                          cartQuantity,
                          productIndex,
                        ),
                child: AnimatedOpacity(
                  opacity: isDisabled ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 16.w),

        // Total Price display
        Expanded(
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.76.w,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 18.w,
                  color: const Color(0xFF101828),
                ),
                SizedBox(width: 8.w),
                Text(
                  'في السلة',
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${(widget.product.price * cartQuantity).toStringAsFixed(0)} د.ل',
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: const Color(0xFF101828),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartBar(
      MarketDetailsController controller, bool isLoading) {
    final isUnavailable = !widget.product.isAvailable;

    return Row(
      children: [
        // Quantity Selector
        Container(
          width: 120.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.76.w,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 20.w,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle().textColorBold(
                  fontSize: 20.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20.w,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 16.w),

        // Add to Cart Button
        Expanded(
          child: CustomButtonApp(
            height: 40.h,
            borderRadius: 20.r,
            color: isUnavailable
                ? Colors.grey
                : const Color(0xFF101828),
            onTap: (isLoading || isUnavailable)
                ? null
                : () async {
                    await controller.addToCart(
                      marketProductId: widget.product.id,
                      quantity: quantity,
                      notes: notesController.text.isNotEmpty
                          ? notesController.text
                          : null,
                    );

                    if (mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
            childWidget: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${totalPrice.toStringAsFixed(0)} د.ل',
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isUnavailable ? 'غير متوفر' : 'إضافة للسلة',
                        style: const TextStyle().textColorBold(
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        isUnavailable
                            ? Icons.block
                            : Icons.shopping_cart,
                        size: 20.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
