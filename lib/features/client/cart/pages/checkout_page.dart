import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addressController.fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: CustomAppBar(
        title: 'إتمام الطلب',
        backgroundColor: const Color(0xFFF9FAFB),
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
                            // Delivery Address Section

                            // Payment Method Section

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Button
              _buildBottomButton(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      // height: 120.h,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE0DDDD), width: 1.w),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/orders/order_checkout_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset("assets/svg/cart/map_group_icon.svg"),
          SizedBox(height: 20.h),
          _buildDeliveryAddressSection(),
          // SizedBox(height: 24.h),
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
            color: const Color(0xFF697282),
            fontSize: 14,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 0.761),
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
                          color: const Color(0xFFF3F4F6),
                          width: 0.761,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Text("${item.quantity}x"),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child:  Text(
                        '${item.item.name}',
                        style: const TextStyle().textColorMedium(
                          fontSize: 14.sp,
                          color: Color(0xFF101828),
                        ),
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} د.ل',
                      style: const TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: Color(0xFF101828),
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
                 const Divider(color: Color(0xFFF3F4F6)),
                 Container( height: 10, ),
                 Text(
                  'المشروبات',
                  style: const TextStyle().textColorBold(
                    fontSize: 12.sp,
                    color: Color(0xFF697282),
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
                                color: const Color(0xFFF3F4F6),
                                width: 0.761,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Text("${drink['quantity']}x"),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${drink['name']}',
                                  style: const TextStyle().textColorMedium(
                                    fontSize: 14.sp,
                                    color: Color(0xFF101828),
                                  ),
                                ),
                                if (drink['notes'] != null && drink['notes'].toString().isNotEmpty)
                                  Text(
                                    '${drink['notes']}',
                                    style: const TextStyle().textColorNormal(
                                      fontSize: 12.sp,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${((drink['price'] as num) * (drink['quantity'] as int)).toStringAsFixed(0)} د.ل',
                            style: const TextStyle().textColorBold(
                              fontSize: 14.sp,
                              color: Color(0xFF101828),
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
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
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
                    style: const TextStyle().textColorMedium(
                      fontSize: 14.sp,
                      color: Color(0xFF7F22FE),
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
          color: Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.76, color: const Color(0xFFF2F4F6)),
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
                color: const Color(0xFFF9FAFB),
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
                    style: const TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Color(0xFF101828),
                    ),
                  ),
                  // SizedBox(height: 4.h),
                  Text(
                    activeAddress.address,
                    style: const TextStyle().textColorNormal(
                      fontSize: 14.sp,
                      color: Color(0xFF6A7282),
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
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.76, color: const Color(0xFFE5E7EB)),
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
                style: const TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: Color(0xFF101828),
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
                  color: const Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.r),
                child: _getPaymentIcon(selectedPaymentMethod),
              ),
              SizedBox(width: 12.w),
              Text(
                _getPaymentMethodName(selectedPaymentMethod),
                style: const TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Color(0xFF101828),
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
        return Icon(Icons.money, color: const Color(0xFF101828), size: 20.r);
        // return SvgPicture.asset("assets/svg/client/delivery-bike.svg", color: const Color(0xFF101828)); 
      case PaymentMethod.card: // Making 'card' represent 'banking' for now or generic card
        return SvgPicture.asset("assets/svg/wallet/bank_card_outline.svg", color: const Color(0xFF101828));
      case PaymentMethod.wallet:
        return SvgPicture.asset("assets/svg/nav/wallet.svg", color: const Color(0xFF101828));
      default:
        return Icon(Icons.payment, color: const Color(0xFF101828), size: 20.r);
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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Obx(() {
            double walletBalance = walletController.wallet.value?.balance ?? 0.0;
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
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'اختر طريقة الدفع',
                      style: const TextStyle().textColorBold(
                        fontSize: 18.sp,
                        color: Color(0xFF101828),
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
                                    color: selectedPaymentMethod == PaymentMethod.wallet ? const Color(0xFF7F22FE) : const Color(0xFF6A7282),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 16.h),
                                      Text(
                                        '${walletBalance.toStringAsFixed(1)} د.ل',
                                        style: const TextStyle().textColorBold(
                                          fontSize: 16.sp,
                                          color: Color(0xFF101828),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'الرصيد المتاح',
                                        style: const TextStyle().textColorNormal(
                                          fontSize: 12.sp,
                                          color: Color(0xFF6A7282),
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
                                    style: const TextStyle().textColorBold(
                                      fontSize: 14.sp,
                                      color: selectedPaymentMethod == PaymentMethod.wallet ? const Color(0xFF7F22FE) : const Color(0xFF101828),
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
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money, size: 40.r, color: selectedPaymentMethod == PaymentMethod.cash ? const Color(0xFF7F22FE) : const Color(0xFF6A7282)),
                                SizedBox(height: 12.h),
                                Text(
                                  'الدفع عند الاستلام',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle().textColorBold(
                                    fontSize: 14.sp,
                                    color: selectedPaymentMethod == PaymentMethod.cash ? const Color(0xFF7F22FE) : const Color(0xFF101828),
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
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/wallet/bank_card_outline.svg",
                                   width: 40.w,
                                   height: 40.h,
                                   color: selectedPaymentMethod == PaymentMethod.card ? const Color(0xFF7F22FE) : const Color(0xFF6A7282)
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'الخدمات المصرفية',
                                  textAlign: TextAlign.center,
                                   style: const TextStyle().textColorBold(
                                    fontSize: 14.sp,
                                    color: selectedPaymentMethod == PaymentMethod.card ? const Color(0xFF7F22FE) : const Color(0xFF101828),
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
          color: isSelected ? const Color(0xFF7F22FE).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF7F22FE) : const Color(0xFFF3F4F6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final activeAddress = addressController.activeAddress.value;
        final hasAddress = activeAddress != null;
        
        final walletBalance = walletController.wallet.value?.balance ?? 0.0;
        final orderTotal = widget.cart.totalPrice;
        final isWalletBalanceEnough = walletBalance >= orderTotal;
        final isWalletSelected = selectedPaymentMethod == PaymentMethod.wallet;

        return CustomButtonApp(
          text: (isWalletSelected && !isWalletBalanceEnough) ? 'تعبئة المحفظة' : 'إتمام الطلب',
          isLoading: cartController.isLoading,
          isEnable: hasAddress,
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
                      payment: paymentStr,
                      notes: '',
                    );
                  }
                }
              : null,
          color: const Color(0xFF7F22FE),
        );
      }),
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
