import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/market_cart_model.dart';
import '../../address/controllers/address_controller.dart';
import '../../address/models/address_model.dart';
import '../../wallet/controllers/client_wallet_controller.dart';

enum MarketPaymentMethod { cash, card, wallet }

class MarketCheckoutPage extends StatefulWidget {
  final MarketCartResponse cart;
  const MarketCheckoutPage({super.key, required this.cart});

  @override
  State<MarketCheckoutPage> createState() => _MarketCheckoutPageState();
}

class _MarketCheckoutPageState extends State<MarketCheckoutPage> {
  final AddressController addressController = Get.put(AddressController());
  final ClientWalletController walletController =
      Get.put(ClientWalletController());
  MarketPaymentMethod selectedPaymentMethod = MarketPaymentMethod.cash;
  Worker? _addressWorker;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isBillExpanded = false;
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressWorker?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

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

  Widget _buildHeaderSection() {
    final activeAddress = addressController.activeAddress.value;
    final initialPos = activeAddress != null
        ? LatLng(activeAddress.lat, activeAddress.long)
        : const LatLng(32.8872, 13.1913);

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
            padding:
                EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
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
              child:
                  SvgPicture.asset("assets/svg/cart/map_group_icon.svg"),
            ),
          ),
        ],
      ),
    );
  }

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
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 1),
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
                    'عنوان التوصيل',
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
        return SvgPicture.asset("assets/svg/wallet/bank_card_outline.svg",
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                                    : Theme.of(context).iconTheme.color,
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
                                    style: TextStyle().textColorNormal(
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
                                  : Theme.of(context).iconTheme.color,
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

  Widget _buildPaymentSelectionCard(
      {required bool isSelected,
      required VoidCallback onTap,
      required Widget child}) {
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
            itemBuilder: (context, index) {
              final product = widget.cart.products[index];
              return Row(
                children: [
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
                    child: Text("${product.quantity}x",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primary)),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      product.marketProduct.product.name,
                      style: TextStyle().textColorMedium(
                        fontSize: 14.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color,
                      ),
                    ),
                  ),
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
            separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
            itemCount: widget.cart.products.length,
          ),
        ),
      ],
    );
  }

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
      child: Column(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

          // Place Order Button
          Obx(() {
            final activeAddress = addressController.activeAddress.value;
            final hasAddress = activeAddress != null;
            final walletBalance =
                walletController.wallet.value?.balance ?? 0.0;
            final isWalletBalanceEnough =
                walletBalance >= widget.cart.totalPrice;
            final isWalletSelected =
                selectedPaymentMethod == MarketPaymentMethod.wallet;

            return CustomButtonApp(
              text: (isWalletSelected && !isWalletBalanceEnough)
                  ? 'تعبئة المحفظة'
                  : 'إتمام الطلب',
              isLoading: _isPlacingOrder,
              isEnable: hasAddress,
              childWidget: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isPlacingOrder)
                    const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white))
                  else
                    Text(
                      (isWalletSelected && !isWalletBalanceEnough)
                          ? 'تعبئة المحفظة'
                          : 'إتمام الطلب',
                      style: TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  if (!_isPlacingOrder) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '${widget.cart.totalPrice.toStringAsFixed(1)} د.ل',
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
                      if (isWalletSelected && !isWalletBalanceEnough) {
                        Get.toNamed(AppRoutes.wallet);
                        return;
                      }
                      // TODO: Implement market order placement
                      // This needs a createMarketOrder API
                      showSnackBar(
                        title: 'قريبا',
                        message: 'سيتم تفعيل طلبات الماركت قريبا',
                        isSuccess: true,
                      );
                    }
                  : null,
              color: const Color(0xFF4D179A),
            );
          }),

          // Expandable Bill Details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                SizedBox(height: 16.h),
                _buildBillRow("المجموع الفرعي", widget.cart.totalPrice),
                SizedBox(height: 12.h),
                _buildBillRow("التوصيل", 0,
                    valueText: 'يحسب عند التأكيد'),
                SizedBox(height: 12.h),
                const Divider(height: 1),
                SizedBox(height: 12.h),
                _buildBillRow(
                  "المجموع الكلي",
                  widget.cart.totalPrice,
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
      ),
    );
  }

  Widget _buildBillRow(String label, double amount,
      {bool isBold = false, double fontSize = 14, String? valueText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? TextStyle().textColorBold(
                  fontSize: fontSize.sp,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color)
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
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color)
              : TextStyle().textColorBold(
                  fontSize: fontSize.sp,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ],
    );
  }
}
