import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
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
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../../address/controllers/address_controller.dart';
import '../../address/models/address_model.dart';
import '../../wallet/controllers/client_wallet_controller.dart';

enum PaymentMethod { cash, card, wallet }

class CheckoutPage extends StatefulWidget {
  final RestaurantCartResponse cart;
  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController cartController = Get.find<CartController>();
  final AddressController addressController = Get.put(AddressController());
  final ClientWalletController walletController = Get.put(ClientWalletController());
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash;
  Worker? _addressWorker;
  Worker? _paymentWorker; // Also listen to payment method changes logic if needed, but keeping it simple for now.

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isBillExpanded = false;

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
         _calculatePrice(address);
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      };
    });
  }

  void _calculatePrice(AddressModel address) {
    String paymentStr = 'cash';
    if (selectedPaymentMethod == PaymentMethod.card) {
      paymentStr = 'gateway';
    } else if (selectedPaymentMethod == PaymentMethod.wallet) {
      paymentStr = 'wallet';
    }

    cartController.calculateOrderPrice(
      restaurantId: widget.cart.restaurant.id!,
      addressId: address.id,
      deliveryAddress: address.address,
      deliveryLat: address.lat,
      deliveryLong: address.long,
      paymentMethod: paymentStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'إتمام الطلب',
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
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

                            // Order Summary Section
                            _buildOrderSummarySection(),
                            SizedBox(height: 24.h),
                            
                            // Bill Details (Moved to bottom summary)
                            // _buildBillDetailsSection(),
                            // SizedBox(height: 24.h), 
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Section (Includes Expandable Bill Details)
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
        : const LatLng(32.8872, 13.1913); // Default Tripoli

    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE0DDDD), width: 1.w),
        ),
      ),
      child: Stack(
        children: [
          // Google Map Background
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
          // Overlay content
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
          // Floating Icon to match original design intent (optional)
          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset("assets/svg/cart/map_group_icon.svg"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العناصر',
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
            border: Border.all(color: Theme.of(context).dividerColor, width: 0.761),
          ),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items List
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                final item = widget.cart.items[index];
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Text("${item.quantity}x", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child:  Text(
                        '${item.item.name}',
                        style: TextStyle().textColorMedium(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} د.ل',
                      style: TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                );
              },
                  separatorBuilder: (context, index) => Container( height: 10, ),
                  itemCount: widget.cart.items.length),
              
              // Drinks List
              if (cartController.selectedDrinks.isNotEmpty) ...[
                 Container( height: 10, ),
                 Divider(color: Theme.of(context).dividerColor),
                 Container( height: 10, ),
                 Text(
                  'المشروبات',
                  style: TextStyle().textColorBold(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
                SizedBox(height: 8.h),
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final drink = cartController.selectedDrinks[index];
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Text("${drink['quantity']}x", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${drink['name']}',
                                  style: TextStyle().textColorMedium(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                if (drink['notes'] != null && drink['notes'].toString().isNotEmpty)
                                  Text(
                                    '${drink['notes']}',
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
                          Text(
                            '${((drink['price'] as num) * (drink['quantity'] as int)).toStringAsFixed(0)} د.ل',
                            style: TextStyle().textColorBold(
                              fontSize: 14.sp,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => Container(height: 10),
                    itemCount: cartController.selectedDrinks.length),
              ],



            ],
          ),
        ),
      ],
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
              border: Border.all(color: Theme.of(context).dividerColor, width: 1),
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
            side: BorderSide(width: 0.76, color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
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
            // Location Icon
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
            // Address Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDeliveryTimeText(activeAddress),
                    style: TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  // SizedBox(height: 4.h),
                  Text(
                    activeAddress.address,
                    style: TextStyle().textColorNormal(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
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
                // Open address list in selection mode
                final selectedAddress = await Get.toNamed(
                  AppRoutes.addressList,
                  arguments: true, // Pass true to indicate selection mode
                );

                // If an address was selected, set it as active
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
                    color: Color(0xFF7F22FE),
                  ),
                ),
              ),
              color: Color(0x197F22FE),
              height: 28.h,
              //   style: TextButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10.r),
              //     ),
              //     minimumSize: Size.zero,
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              // ),
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
          side: BorderSide(width: 0.76, color: Theme.of(context).dividerColor),
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
                  color: Theme.of(context).textTheme.titleMedium?.color,
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
                      color: Color(0xFF7F22FE),
                    ),
                  ),
                ),
                color: Color(0x197F22FE),
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icon(Icons.money, color: Theme.of(context).iconTheme.color, size: 20.r);
        // return SvgPicture.asset("assets/svg/client/delivery-bike.svg", color: const Color(0xFF101828)); 
      case PaymentMethod.card: // Making 'card' represent 'banking' for now or generic card
        return SvgPicture.asset("assets/svg/wallet/bank_card_outline.svg", color: Theme.of(context).iconTheme.color);
      case PaymentMethod.wallet:
        return SvgPicture.asset("assets/svg/nav/wallet.svg", color: Theme.of(context).iconTheme.color);
      default:
        return Icon(Icons.payment, color: Theme.of(context).iconTheme.color, size: 20.r);
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'الدفع عند الاستلام';
      case PaymentMethod.card:
        return 'الخدمات المصرفية';
      case PaymentMethod.wallet:
        return 'المحفظة';
      default:
        return 'غير محدد';
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
            double walletBalance = walletController.wallet.value?.balance ?? 0.0;
            final calculated = cartController.calculatedPrice.value;
            double orderTotal = calculated != null ? calculated.totalPrice : widget.cart.totalPrice;
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
                        color: Theme.of(context).textTheme.titleLarge?.color,
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
                          // 1. Wallet
                          _buildPaymentSelectionCard(
                            isSelected: selectedPaymentMethod == PaymentMethod.wallet,
                            onTap: () {
                              setStateBottomSheet(() {
                                 selectedPaymentMethod = PaymentMethod.wallet; 
                              });
                              setState(() {});
                              if (addressController.activeAddress.value != null) {
                                _calculatePrice(addressController.activeAddress.value!);
                              } 
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
                                    color: selectedPaymentMethod == PaymentMethod.wallet ? const Color(0xFF7F22FE) : Theme.of(context).iconTheme.color,
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 16.h),
                                      Text(
                                        '${walletBalance.toStringAsFixed(1)} د.ل',
                                        style: TextStyle().textColorBold(
                                          fontSize: 16.sp,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'الرصيد المتاح',
                                        style: TextStyle().textColorNormal(
                                          fontSize: 12.sp,
                                          color: Theme.of(context).hintColor,
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
                                      color: selectedPaymentMethod == PaymentMethod.wallet ? const Color(0xFF7F22FE) : Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 2. Cash
                          _buildPaymentSelectionCard(
                            isSelected: selectedPaymentMethod == PaymentMethod.cash,
                            onTap: () {
                               setStateBottomSheet(() {
                                 selectedPaymentMethod = PaymentMethod.cash;
                               });
                               setState(() {});
                               if (addressController.activeAddress.value != null) {
                                 _calculatePrice(addressController.activeAddress.value!);
                               }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money, size: 40.r, color: selectedPaymentMethod == PaymentMethod.cash ? const Color(0xFF7F22FE) : Theme.of(context).iconTheme.color),
                                SizedBox(height: 12.h),
                                Text(
                                  'الدفع عند الاستلام',
                                  textAlign: TextAlign.center,
                                  style: TextStyle().textColorBold(
                                    fontSize: 14.sp,
                                    color: selectedPaymentMethod == PaymentMethod.cash ? const Color(0xFF7F22FE) : Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 3. Banking
                          _buildPaymentSelectionCard(
                            isSelected: selectedPaymentMethod == PaymentMethod.card, // mapped to banking
                            onTap: () {
                               setStateBottomSheet(() {
                                 selectedPaymentMethod = PaymentMethod.card;
                               });
                               setState(() {});
                               if (addressController.activeAddress.value != null) {
                                 _calculatePrice(addressController.activeAddress.value!);
                               }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/wallet/bank_card_outline.svg",
                                   width: 40.w,
                                   height: 40.h,
                                   color: selectedPaymentMethod == PaymentMethod.card ? const Color(0xFF7F22FE) : Theme.of(context).iconTheme.color
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'الخدمات المصرفية',
                                  textAlign: TextAlign.center,
                                   style: TextStyle().textColorBold(
                                    fontSize: 14.sp,
                                    color: selectedPaymentMethod == PaymentMethod.card ? const Color(0xFF7F22FE) : Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),


                    SizedBox(height: 32.h),
                    
                    // Bottom Button
                    CustomButtonApp(
                      text: (selectedPaymentMethod == PaymentMethod.wallet && !isWalletBalanceEnough)
                          ? 'تعبئة المحفظة'
                          : 'تأكيد الاختيار',
                      color: (selectedPaymentMethod == PaymentMethod.wallet && !isWalletBalanceEnough)
                          ? AppColors.notificationRed // Distinct color for top-up
                          : const Color(0xFF7F22FE),
                      onTap: () {
                        if (selectedPaymentMethod == PaymentMethod.wallet && !isWalletBalanceEnough) {
                          // Navigate to top-up (ClientWalletPage)
                          Get.back(); // Close sheet
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

  Widget _buildPaymentSelectionCard({required bool isSelected, required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: 140.w, // Remove fixed width for GridView
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7F22FE).withOpacity(0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF7F22FE) : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.only(top: 16.h, left: 24.w, right: 24.w, bottom: 24.h),
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
        final calculated = cartController.calculatedPrice.value;
        final subtotal = calculated?.subtotal ?? widget.cart.totalPrice;
        final total = calculated?.totalPrice ?? subtotal;
        final activeAddress = addressController.activeAddress.value;
        final hasAddress = activeAddress != null;
        
        final walletBalance = walletController.wallet.value?.balance ?? 0.0;
        final isWalletBalanceEnough = walletBalance >= total;
        final isWalletSelected = selectedPaymentMethod == PaymentMethod.wallet;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chevron Icon (Left in RTL)
                    Transform.rotate(
                      angle: _isBillExpanded ? 3.14159 : 0,
                      child: SvgPicture.asset(
                        'assets/svg/cart/arrow-top.svg',
                        width: 20.w,
                        height: 20.h,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    // Bill Title (Right in RTL)
                    Text(
                      'ملخص الفاتورة',
                      style: TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Order Button
            CustomButtonApp(
              text: (isWalletSelected && !isWalletBalanceEnough) ? 'تعبئة المحفظة' : 'إتمام الطلب',
              isLoading: cartController.isLoading,
              isEnable: hasAddress,
              childWidget: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (cartController.isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.white))
                  else
                    Text(
                      (isWalletSelected && !isWalletBalanceEnough) ? 'تعبئة المحفظة' : 'إتمام الطلب',
                      style: TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),

                  if (!cartController.isLoading)
                    ...[
                      SizedBox(width: 8.w),
                      Text(
                      '${total.toStringAsFixed(1)} د.ل',
                      style: TextStyle().textColorBold(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    )],
                ],
              ),
              onTap: hasAddress
                  ? () {
                      if (isWalletSelected && !isWalletBalanceEnough) {
                        Get.toNamed(AppRoutes.wallet);
                        return;
                      }
                      final address = addressController.activeAddress.value;
                      if (address != null) {
                        String paymentStr = 'cash';
                        if (selectedPaymentMethod == PaymentMethod.card) {
                          paymentStr = 'gateway';
                        } else if (selectedPaymentMethod == PaymentMethod.wallet) {
                          paymentStr = 'wallet';
                        }

                        cartController.placeOrder(
                          restaurantId: widget.cart.restaurant.id!,
                          addressId: address.id,
                          deliveryAddress: address.address,
                          deliveryLat: address.lat,
                          deliveryLong: address.long,
                          restaurantLat: widget.cart.restaurant.lat,
                          restaurantLong: widget.cart.restaurant.long,
                          payment: paymentStr,
                          notes: '',
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
                  if (calculated?.deliveryFee != null) ...[
                    SizedBox(height: 12.h),
                    _buildBillRow("التوصيل", calculated!.deliveryFee),
                  ],
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "رسوم الخدمة",
                        style: TextStyle().textColorNormal(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      Text(
                        "مجانًا",
                        style: TextStyle().textColorBold(fontSize: 14.sp, color: Colors.green),
                      ),
                    ],
                  ),
                  if(calculated?.deliveryFeeDetails != null && calculated!.deliveryFeeDetails!.isNight)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Row(
                        children: [
                          Icon(Icons.nightlight_round, size: 14.sp, color: Colors.orange),
                          SizedBox(width: 4.w),
                          Text("توصيل ليلي", style: TextStyle(fontSize: 12.sp, color: Colors.orange)),
                        ],
                      ),
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
              crossFadeState: _isBillExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        );
      }),
    );
  }

  // Remove old _buildBottomButton and _buildBillDetailsSection if they are no longer used
  // I will keep _buildBillRow as it is useful for the expandable section.

  Widget _buildBillRow(String label, double amount, {bool isBold = false, double fontSize = 14, String? valueText}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold 
             ? TextStyle().textColorBold(fontSize: fontSize.sp, color: Theme.of(context).textTheme.bodyLarge?.color)
             : TextStyle().textColorNormal(fontSize: fontSize.sp, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          Text(
            valueText ?? '${amount.toStringAsFixed(1)} د.ل', 
             style: isBold 
             ? TextStyle().textColorBold(fontSize: fontSize.sp, color: Theme.of(context).textTheme.bodyLarge?.color)
             : TextStyle().textColorBold(fontSize: fontSize.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
          )
        ],
      );
  }

  String _getDeliveryTimeText(AddressModel deliveryAddress) {
    // Check if restaurant has coordinates
    if (widget.cart.restaurant.lat == null ||
        widget.cart.restaurant.long == null) {
      return '-- دقيقة';
    }

    // Calculate delivery time
    final deliveryTime = LocationUtils.calculateDeliveryTime(
      restaurantLat: widget.cart.restaurant.lat!,
      restaurantLong: widget.cart.restaurant.long!,
      deliveryLat: deliveryAddress.lat,
      deliveryLong: deliveryAddress.long,
    );

    // Format and return
    return LocationUtils.formatDeliveryTime(deliveryTime);
  }
}
