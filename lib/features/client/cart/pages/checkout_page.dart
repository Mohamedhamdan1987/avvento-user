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
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../../address/controllers/address_controller.dart';
import '../../address/models/address_model.dart';

enum PaymentMethod { cash, card }

class CheckoutPage extends StatefulWidget {
  final RestaurantCartResponse cart;
  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController cartController = Get.find<CartController>();
  final AddressController addressController = Get.put(AddressController());
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items List
              ...widget.cart.items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 0.h),
                  child: Row(
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
                  ),
                ),
              ),


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
      // decoration: ShapeDecoration(
      //   color: Colors.white.withValues(alpha: 0.95),
      //   shape: RoundedRectangleBorder(
      //     side: BorderSide(width: 0.76, color: const Color(0xFFF2F4F6)),
      //     borderRadius: BorderRadius.circular(16),
      //   ),
      //   shadows: [
      //     BoxShadow(
      //       color: Color(0x19000000),
      //       blurRadius: 1,
      //       offset: Offset(0, 1),
      //       spreadRadius: 0,
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طريقة الدفع',
            style: const TextStyle().textColorBold(
              fontSize: 18.sp,
              color: Color(0xFF101828),
            ),
          ),
          SizedBox(height: 16.h),
          // Cash Payment
          _buildPaymentMethodOption(
            method: PaymentMethod.cash,
            title: 'الدفع عند الاستلام',
            icon: Icons.money,
          ),
          SizedBox(height: 12.h),
          // Card Payment
          _buildPaymentMethodOption(
            method: PaymentMethod.card,
            title: 'الدفع بالبطاقة',
            icon: Icons.credit_card,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required PaymentMethod method,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
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
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7F22FE).withOpacity(0.1)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF7F22FE)
                    : const Color(0xFF6A7282),
                size: 24.r,
              ),
            ),
            SizedBox(width: 12.w),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: Color(0xFF101828),
                ),
              ),
            ),
            // Radio Button
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7F22FE)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF7F22FE)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16.r)
                  : null,
            ),
          ],
        ),
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

        return CustomButtonApp(
          text: 'إتمام الطلب',
          isLoading: cartController.isLoading,
          isEnable: hasAddress,
          onTap: hasAddress
              ? () {
                  final address = addressController.activeAddress.value;
                  if (address != null) {
                    cartController.placeOrder(
                      restaurantId: widget.cart.restaurant.id!,
                      deliveryAddress: address.address,
                      deliveryLat: address.lat,
                      deliveryLong: address.long,
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
    print("lat::: ${widget.cart.restaurant.lat}");
    print("long::: ${widget.cart.restaurant.long}");
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
