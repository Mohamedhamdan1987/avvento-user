import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/webview/SmartWebView.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../controllers/market_cart_controller.dart';
import '../models/market_cart_model.dart';
import '../../address/controllers/address_controller.dart';
import '../../address/models/address_model.dart';
import '../../wallet/controllers/client_wallet_controller.dart';
import '../../orders/services/orders_service.dart';
import 'package:get_storage/get_storage.dart';

enum MarketPaymentMethod { cash, card, wallet }

class MarketCheckoutPage extends StatefulWidget {
  final MarketCartResponse cart;
  const MarketCheckoutPage({super.key, required this.cart});

  @override
  State<MarketCheckoutPage> createState() => _MarketCheckoutPageState();
}

class _MarketCheckoutPageState extends State<MarketCheckoutPage> {
  final MarketCartController cartController =
      Get.find<MarketCartController>();
  final OrdersService _ordersService = OrdersService();
  final AddressController addressController = Get.put(AddressController());
  final ClientWalletController walletController =
      Get.put(ClientWalletController());

  MarketPaymentMethod selectedPaymentMethod = MarketPaymentMethod.cash;
  final TextEditingController _notesController = TextEditingController();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isBillExpanded = false;
  Worker? _addressWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addressController.fetchAddresses();
    });

    _addressWorker = ever(addressController.activeAddress, (address) {
      if (address != null) {
        _updateMapLocation(address);
      }
    });
  }

  @override
  void dispose() {
    _addressWorker?.dispose();
    _mapController?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateMapLocation(AddressModel address) {
    if (_mapController == null) return;

    final latLng = LatLng(address.lat, address.long);
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('delivery_location'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet),
        ),
      };
    });
  }

  String _getPaymentString() {
    switch (selectedPaymentMethod) {
      case MarketPaymentMethod.cash:
        return 'cash';
      case MarketPaymentMethod.card:
        return 'gateway';
      case MarketPaymentMethod.wallet:
        return 'wallet';
    }
  }

  Future<void> _openNavigationToActiveAddress() async {
    final activeAddress = addressController.activeAddress.value;
    if (activeAddress == null) return;
    _updateMapLocation(activeAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'إتمام الطلب',
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (addressController.isLoading.value &&
              addressController.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderSection(),
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPaymentMethodSection(),
                            SizedBox(height: 24.h),
                            _buildOrderSummarySection(),
                            SizedBox(height: 24.h),
                            _buildNotesSection(),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          );
        }),
      ),
    );
  }

  // ─── Header Section with Map ──────────────────────────────────────
  Widget _buildHeaderSection() {
    final activeAddress = addressController.activeAddress.value;
    final initialPos = activeAddress != null
        ? LatLng(activeAddress.lat, activeAddress.long)
        : LatLng(
            LocationUtils.currentLatitude ?? 32.8872,
            LocationUtils.currentLongitude ?? 13.1913,
          );

    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE0DDDD), width: 1.w),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPos,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (activeAddress != null) {
                  _updateMapLocation(activeAddress);
                }
              },
              markers: _markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.8),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildDeliveryAddressSection(),
              ],
            ),
          ),
          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset("assets/svg/cart/map_group_icon.svg"),
            ),
          ),
          Positioned(
            top: 16.h,
            left: 16.w,
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: _openNavigationToActiveAddress,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Icon(
                    Icons.navigation_rounded,
                    color: const Color(0xFF7F22FE),
                    size: 20.r,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Delivery Address Section ─────────────────────────────────────
  Widget _buildDeliveryAddressSection() {
    return Obx(() {
      final activeAddress = addressController.activeAddress.value;
      if (activeAddress == null) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.addressList);
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: Theme.of(context).dividerColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_location_alt,
                  color: const Color(0xFF7F22FE),
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'إضافة عنوان جديد',
                    style: TextStyle().textColorMedium(
                      fontSize: 14.sp,
                      color: const Color(0xFF7F22FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: ShapeDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 0.76, color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 1,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(10.r),
              child: SvgPicture.asset("assets/svg/cart/clock.svg"),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDeliveryTimeText(activeAddress),
                    style: TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.color,
                    ),
                  ),
                  Text(
                    activeAddress.address,
                    style: TextStyle().textColorNormal(
                      fontSize: 14.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            CustomButtonApp(
              onTap: () async {
                final selectedAddress = await Get.toNamed(
                  AppRoutes.addressList,
                  arguments: true,
                );
                if (selectedAddress != null &&
                    selectedAddress is AddressModel) {
                  addressController.setActive(selectedAddress.id);
                }
              },
              childWidget: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'تغيير',
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: const Color(0xFF7F22FE),
                  ),
                ),
              ),
              color: const Color(0x197F22FE),
              height: 28.h,
            ),
          ],
        ),
      );
    });
  }

  // ─── Payment Method Section ───────────────────────────────────────
  Widget _buildPaymentMethodSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 0.76, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طريقة الدفع',
                style: TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              CustomButtonApp(
                onTap: () {
                  _showPaymentMethodBottomSheet();
                },
                childWidget: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'تغيير',
                    style: const TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: const Color(0xFF7F22FE),
                    ),
                  ),
                ),
                color: const Color(0x197F22FE),
                height: 28.h,
                isFill: false,
                borderColor: Colors.transparent,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.r),
                child: _getPaymentIcon(selectedPaymentMethod),
              ),
              SizedBox(width: 12.w),
              Text(
                _getPaymentMethodName(selectedPaymentMethod),
                style: TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPaymentIcon(MarketPaymentMethod method) {
    switch (method) {
      case MarketPaymentMethod.cash:
        return Icon(Icons.money,
            color: Theme.of(context).iconTheme.color, size: 20.r);
      case MarketPaymentMethod.card:
        return SvgPicture.asset(
            "assets/svg/wallet/bank_card_outline.svg",
            color: Theme.of(context).iconTheme.color);
      case MarketPaymentMethod.wallet:
        return SvgPicture.asset("assets/svg/nav/wallet.svg",
            color: Theme.of(context).iconTheme.color);
    }
  }

  String _getPaymentMethodName(MarketPaymentMethod method) {
    switch (method) {
      case MarketPaymentMethod.cash:
        return 'الدفع عند الاستلام';
      case MarketPaymentMethod.card:
        return 'الخدمات المصرفية';
      case MarketPaymentMethod.wallet:
        return 'المحفظة';
    }
  }

  void _showPaymentMethodBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Obx(() {
          double walletBalance =
              walletController.wallet.value?.balance ?? 0.0;
          double orderTotal = widget.cart.totalPrice;
          bool isWalletBalanceEnough = walletBalance >= orderTotal;

          return StatefulBuilder(
            builder: (context, setStateBottomSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2.5.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'اختر طريقة الدفع',
                    style: TextStyle().textColorBold(
                      fontSize: 18.sp,
                      color: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Wallet
                      _buildPaymentSelectionCard(
                        isSelected: selectedPaymentMethod ==
                            MarketPaymentMethod.wallet,
                        onTap: () {
                          setStateBottomSheet(() {
                            selectedPaymentMethod =
                                MarketPaymentMethod.wallet;
                          });
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            PositionedDirectional(
                              top: 8.h,
                              end: 8.w,
                              child: SvgPicture.asset(
                                "assets/svg/nav/wallet.svg",
                                width: 20.w,
                                height: 20.h,
                                color: selectedPaymentMethod ==
                                        MarketPaymentMethod.wallet
                                    ? const Color(0xFF7F22FE)
                                    : Theme.of(context)
                                        .iconTheme
                                        .color,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 16.h),
                                  Text(
                                    '${walletBalance.toStringAsFixed(1)} د.ل',
                                    style: TextStyle().textColorBold(
                                      fontSize: 16.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'الرصيد المتاح',
                                    style:
                                        TextStyle().textColorNormal(
                                      fontSize: 12.sp,
                                      color:
                                          Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 12.h,
                              left: 0,
                              right: 0,
                              child: Text(
                                'المحفظة',
                                textAlign: TextAlign.center,
                                style: TextStyle().textColorBold(
                                  fontSize: 14.sp,
                                  color: selectedPaymentMethod ==
                                          MarketPaymentMethod.wallet
                                      ? const Color(0xFF7F22FE)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cash
                      _buildPaymentSelectionCard(
                        isSelected: selectedPaymentMethod ==
                            MarketPaymentMethod.cash,
                        onTap: () {
                          setStateBottomSheet(() {
                            selectedPaymentMethod =
                                MarketPaymentMethod.cash;
                          });
                          setState(() {});
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.money,
                                size: 40.r,
                                color: selectedPaymentMethod ==
                                        MarketPaymentMethod.cash
                                    ? const Color(0xFF7F22FE)
                                    : Theme.of(context)
                                        .iconTheme
                                        .color),
                            SizedBox(height: 12.h),
                            Text(
                              'الدفع عند الاستلام',
                              textAlign: TextAlign.center,
                              style: TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: selectedPaymentMethod ==
                                        MarketPaymentMethod.cash
                                    ? const Color(0xFF7F22FE)
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Banking
                      _buildPaymentSelectionCard(
                        isSelected: selectedPaymentMethod ==
                            MarketPaymentMethod.card,
                        onTap: () {
                          setStateBottomSheet(() {
                            selectedPaymentMethod =
                                MarketPaymentMethod.card;
                          });
                          setState(() {});
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/wallet/bank_card_outline.svg",
                              width: 40.w,
                              height: 40.h,
                              color: selectedPaymentMethod ==
                                      MarketPaymentMethod.card
                                  ? const Color(0xFF7F22FE)
                                  : Theme.of(context)
                                      .iconTheme
                                      .color,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'الخدمات المصرفية',
                              textAlign: TextAlign.center,
                              style: TextStyle().textColorBold(
                                fontSize: 14.sp,
                                color: selectedPaymentMethod ==
                                        MarketPaymentMethod.card
                                    ? const Color(0xFF7F22FE)
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  CustomButtonApp(
                    text: (selectedPaymentMethod ==
                                MarketPaymentMethod.wallet &&
                            !isWalletBalanceEnough)
                        ? 'تعبئة المحفظة'
                        : 'تأكيد الاختيار',
                    color: (selectedPaymentMethod ==
                                MarketPaymentMethod.wallet &&
                            !isWalletBalanceEnough)
                        ? AppColors.notificationRed
                        : const Color(0xFF7F22FE),
                    onTap: () {
                      if (selectedPaymentMethod ==
                              MarketPaymentMethod.wallet &&
                          !isWalletBalanceEnough) {
                        Get.back();
                        Get.toNamed(AppRoutes.wallet);
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            },
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPaymentSelectionCard({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7F22FE).withOpacity(0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7F22FE)
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }

  // ─── Order Summary Section ────────────────────────────────────────
  Widget _buildOrderSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المنتجات',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall?.color,
            fontSize: 14,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: Theme.of(context).dividerColor, width: 0.761),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget.cart.products.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = widget.cart.products[index];
              return Row(
                children: [
                  // Quantity badge
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x197F22FE),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 0.761,
                      ),
                    ),
                    child: Text(
                      "${product.quantity}x",
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Product image
                  if (product.marketProduct.thumbnailUrl !=
                      null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl:
                            product.marketProduct.thumbnailUrl!,
                        width: 32.w,
                        height: 32.h,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  // Product name
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.marketProduct.product.name,
                          style: TextStyle().textColorMedium(
                            fontSize: 14.sp,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.notes.isNotEmpty)
                          Text(
                            product.notes,
                            style: TextStyle().textColorNormal(
                              fontSize: 12.sp,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Price
                  Text(
                    '${product.totalPrice.toStringAsFixed(0)} د.ل',
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Notes Section ────────────────────────────────────────────────
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall?.color,
            fontSize: 14,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: Theme.of(context).dividerColor, width: 0.761),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'أضف ملاحظات للطلب (اختياري)',
              hintStyle: TextStyle().textColorNormal(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
            style: TextStyle().textColorNormal(
              fontSize: 14.sp,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Section ───────────────────────────────────────────────
  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.only(
          top: 16.h, left: 24.w, right: 24.w, bottom: 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.761,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final subtotal = widget.cart.totalPrice;
        final total = subtotal;
        final activeAddress = addressController.activeAddress.value;
        final hasAddress = activeAddress != null;

        final walletBalance =
            walletController.wallet.value?.balance ?? 0.0;
        final isWalletBalanceEnough = walletBalance >= total;
        final isWalletSelected =
            selectedPaymentMethod == MarketPaymentMethod.wallet;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bill Header (Toggle)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isBillExpanded = !_isBillExpanded;
                });
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.rotate(
                      angle: _isBillExpanded ? 3.14159 : 0,
                      child: SvgPicture.asset(
                        'assets/svg/cart/arrow-top.svg',
                        width: 20.w,
                        height: 20.h,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Text(
                      'ملخص الفاتورة',
                      style: TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Order Button
            CustomButtonApp(
              text: (isWalletSelected && !isWalletBalanceEnough)
                  ? 'تعبئة المحفظة'
                  : 'إتمام الطلب',
              isLoading: cartController.isLoading,
              isEnable: hasAddress,
              childWidget: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  if (cartController.isLoading)
                    const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white))
                  else
                    Text(
                      (isWalletSelected &&
                              !isWalletBalanceEnough)
                          ? 'تعبئة المحفظة'
                          : 'إتمام الطلب',
                      style: TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  if (!cartController.isLoading) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '${total.toStringAsFixed(1)} د.ل',
                      style: TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
              onTap: hasAddress
                  ? () {
                      if (isWalletSelected &&
                          !isWalletBalanceEnough) {
                        Get.toNamed(AppRoutes.wallet);
                        return;
                      }
                      final address =
                          addressController.activeAddress.value;
                      if (address != null) {
                        if (selectedPaymentMethod == MarketPaymentMethod.card) {
                          _startGatewayPaymentAndPlaceMarketOrder(
                            address: address,
                            total: total,
                          );
                          return;
                        }

                        cartController.placeMarketOrder(
                          marketId: widget.cart.market.id,
                          deliveryAddress: address.address,
                          deliveryLat: address.lat,
                          deliveryLong: address.long,
                          paymentMethod: _getPaymentString(),
                          notes: _notesController.text.trim(),
                        );
                      }
                    }
                  : null,
              color: const Color(0xFF4D179A),
            ),

            // Expandable Bill Details
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildBillRow("المجموع الفرعي", subtotal),
                  SizedBox(height: 12.h),
                  _buildBillRow(
                    "رسوم التوصيل",
                    0,
                    valueText: 'يحسب عند التأكيد',
                  ),
                  SizedBox(height: 12.h),
                  const Divider(height: 1),
                  SizedBox(height: 12.h),
                  _buildBillRow(
                    "المجموع الكلي",
                    total,
                    isBold: true,
                    fontSize: 16,
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
              crossFadeState: _isBillExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBillRow(String label, double amount,
      {bool isBold = false,
      double fontSize = 14,
      String? valueText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? TextStyle().textColorBold(
                  fontSize: fontSize.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color)
              : TextStyle().textColorNormal(
                  fontSize: fontSize.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color),
        ),
        Text(
          valueText ?? '${amount.toStringAsFixed(1)} د.ل',
          style: isBold
              ? TextStyle().textColorBold(
                  fontSize: fontSize.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color)
              : TextStyle().textColorBold(
                  fontSize: fontSize.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color),
        ),
      ],
    );
  }

  Future<void> _startGatewayPaymentAndPlaceMarketOrder({
    required AddressModel address,
    required double total,
  }) async {
    try {
      final createdOrderResponse = await _ordersService.createMarketOrder(
        marketId: widget.cart.market.id,
        deliveryAddress: address.address,
        deliveryLat: address.lat,
        deliveryLong: address.long,
        paymentMethod: 'gateway',
        notes: _notesController.text.trim(),
      );

      final dynamic nestedOrder = createdOrderResponse['order'];
      final String orderRef =
          (createdOrderResponse['customRef'] ??
                  createdOrderResponse['orderId'] ??
                  createdOrderResponse['_id'] ??
                  (nestedOrder is Map<String, dynamic> ? nestedOrder['_id'] : null) ??
                  '')
              .toString();

      if (orderRef.isEmpty) {
        showSnackBar(message: 'تم إنشاء الطلب لكن تعذر استخراج مرجع الدفع', isError: true);
        Get.offAllNamed(AppRoutes.clientNavBar, arguments: {'tabIndex': 1});
        return;
      }

      String phone = '0910000000';
      String email = 'customer@example.com';
      final storage = GetStorage();
      final userData = storage.read<Map<String, dynamic>>(AppConstants.userKey);
      if (userData != null) {
        final userPhone = userData['phone'] as String?;
        final userEmail = userData['email'] as String?;
        if (userPhone != null && userPhone.isNotEmpty) phone = userPhone;
        if (userEmail != null && userEmail.isNotEmpty) email = userEmail;
      }

      final paymentInit = await _ordersService.initiatePayment(
        amount: total,
        phone: phone,
        email: email,
        customRef: orderRef,
      );

      if (!paymentInit.success || paymentInit.paymentUrl.isEmpty) {
        showSnackBar(
          message: 'تم إنشاء الطلب لكن تعذر بدء عملية الدفع. أكمل الدفع من طلباتك.',
          isError: true,
        );
        Get.offAllNamed(AppRoutes.clientNavBar, arguments: {'tabIndex': 1});
        return;
      }

      await Get.to(
        () => SmartWebView(
          url: paymentInit.paymentUrl,
          appBar: AppBar(
            title: const Text('الدفع الإلكتروني'),
            backgroundColor: const Color(0xFFF7F7F7),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ],
            leading: Container(),
          ),
          closeWhenUrlContains: 'payment/success',
          onClose: () {
            cartController.fetchAllCarts();
            showSnackBar(message: 'تم إتمام الدفع بنجاح', isSuccess: true);
            Get.offAllNamed(AppRoutes.clientNavBar, arguments: {'tabIndex': 1});
          },
        ),
      );
    } catch (e) {
      showSnackBar(message: 'حدث خطأ أثناء بدء عملية الدفع', isError: true);
    }
  }

  String _getDeliveryTimeText(AddressModel deliveryAddress) {
    if (widget.cart.market.lat == null ||
        widget.cart.market.long == null) {
      return '-- دقيقة';
    }

    final deliveryTime = LocationUtils.calculateDeliveryTime(
      restaurantLat: widget.cart.market.lat!,
      restaurantLong: widget.cart.market.long!,
      deliveryLat: deliveryAddress.lat,
      deliveryLong: deliveryAddress.long,
    );

    return LocationUtils.formatDeliveryTime(deliveryTime);
  }
}
