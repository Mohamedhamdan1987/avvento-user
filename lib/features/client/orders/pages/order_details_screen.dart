import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/enums/order_status.dart';
import '../models/order_model.dart';
import '../widgets/order_tracking_dialog.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: CustomAppBar(title: 'تفاصيل الطلب',),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Card
                _buildOrderCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildOrderCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar
          _buildProgressBar(),
          
          SizedBox(height: 40.h),
          
          // Order Header
          _buildOrderHeader(),
          
          SizedBox(height: 24.h),
          
          // Estimated Time Section
          if (order.status != 'delivered' && order.status != 'cancelled' && order.status != 'completed')
            _buildEstimatedTimeSection(),
          
          SizedBox(height: 24.h),
          
          // Order Items
          _buildOrderItems(),
          
          SizedBox(height: 24.h),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final status = OrderStatus.fromString(order.status);
    int completedSteps = _getCompletedSteps(status);
    // Total steps excluding 'cancelled'
    int totalSteps = OrderStatus.values.where((e) => e != OrderStatus.cancelled).length;
    
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          bool isCompleted = completedSteps >= index;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF7F22FE) : Colors.transparent,
                borderRadius: BorderRadius.circular(3.r),
                border: isCompleted && index < totalSteps - 1
                    ? BorderDirectional(end: BorderSide(color: Colors.white, width: 0.76.w))
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  int _getCompletedSteps(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingRestaurant: return 0;
      case OrderStatus.confirmed: return 1;
      case OrderStatus.preparing: return 2;
      case OrderStatus.onTheWay: return 3;
      case OrderStatus.awaitingDelivery: return 4;
      case OrderStatus.delivered: return 5;
      case OrderStatus.cancelled: return -1;
      default: return -1;
    }
  }

  Widget _buildOrderHeader() {
    final status = OrderStatus.fromString(order.status);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Order Number
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '#${order.id.substring(order.id.length - 4)}',
            style: const TextStyle().textColorBold(
              fontSize: 12.sp,
              color: Color(0xFF99A1AF),
            ),
          ),
        ),
        
        // Restaurant Info
        Expanded(
          child: Row(
            children: [
              // Restaurant Image
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 0.76.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: order.restaurant.logo ?? '',
                    width: 56.w,
                    height: 56.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF9FAFB),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Restaurant Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      style: const TextStyle().textColorBold(
                        fontSize: 18.sp,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            status.label,
                            style: TextStyle().textColorBold(
                              fontSize: 12.sp,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingRestaurant: return const Color(0xFF7F22FE);
      case OrderStatus.confirmed: return const Color(0xFF00C950);
      case OrderStatus.preparing: return const Color(0xFF7F22FE);
      case OrderStatus.onTheWay: return const Color(0xFF7F22FE);
      case OrderStatus.delivered: return const Color(0xFF00C950);
      default: return const Color(0xFF7F22FE);
    }
  }

  Widget _buildEstimatedTimeSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child:  Center(
              child: SvgIcon(
                iconName: 'assets/svg/client/orders/clock_icon.svg',
                width: 24.w,
                height: 24.h,
                color: Color(0xFF101828),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Time Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت الوصول المتوقع',
                  style: const TextStyle().textColorNormal(
                    fontSize: 12.sp,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '12:45 م',
                  style: const TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يصل خلال 15-20 دقيقة',
                  style: const TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: const Color(0xFF00A63E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'محتويات الطلب',
          style: const TextStyle().textColorBold(fontSize: 14.sp, color: Color(0xFF101828)),
        ),
        SizedBox(height: 12.h),
        ...order.items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.name}', 
                      style: const TextStyle().textColorNormal(fontSize: 14.sp, color: Color(0xFF101828)),
                    ),
                  ),
                  Text(
                    '${item.totalPrice} د.ل',
                    style: const TextStyle().textColorBold(fontSize: 14.sp, color: Color(0xFF101828)),
                  ),
                ],
              ),
              if (item.selectedVariations.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  'التفضيلات: ${item.selectedVariations.join(', ')}',
                  style: const TextStyle().textColorNormal(fontSize: 12.sp, color: Color(0xFF667085)),
                ),
              ],
              if (item.selectedAddOns.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  'الإضافات: ${item.selectedAddOns.join(', ')}',
                  style: const TextStyle().textColorNormal(fontSize: 12.sp, color: Color(0xFF667085)),
                ),
              ],
               if (item.notes.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  'ملاحظات: ${item.notes}',
                  style: const TextStyle().textColorNormal(fontSize: 12.sp, color: Color(0xFF667085)),
                ),
              ],
            ],
          ),
        )),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإجمالي',
              style: const TextStyle().textColorBold(fontSize: 16.sp, color: Color(0xFF101828)),
            ),
            Text(
              '${order.totalPrice} د.ل',
              style: const TextStyle().textColorBold(fontSize: 18.sp, color: Color(0xFF7F22FE)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Support Button
        Expanded(
          child: CustomButtonApp(
            text: 'الدعم',
            onTap: () {
              Get.toNamed('/restaurantSupport');
            },
            height: 48.h,
            borderRadius: 14.r,
            isFill: false,
            borderColor: const Color(0xFFE5E7EB),
            borderWidth: 0.76.w,
            color: Colors.white,
            textStyle: const TextStyle().textColorBold(
              fontSize: 14.sp,
              color: Color(0xFF101828),
            ),
            childWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SvgIcon(
                  iconName: 'assets/svg/client/orders/support_icon.svg',
                  width: 16.w,
                  height: 16.h,
                  color: Color(0xFF101828),
                ),
                SizedBox(width: 8.w),
                Text(
                  'الدعم',
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: const Color(0xFF101828),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (order.status != 'delivered' && order.status != 'cancelled' && order.status != 'completed') ...[
          SizedBox(width: 12.w),
          // Track Order Button
          Expanded(
            flex: 2,
            child: CustomButtonApp(
              text: 'تتبع الطلب',
              onTap: () {
                 final status = OrderStatus.fromString(order.status);
                 Get.toNamed('/orderTrackingMap', arguments: {
                  'userLat': order.deliveryLat,
                  'userLong': order.deliveryLong,
                  'restaurantLat': order.deliveryLat, // Fallback
                  'restaurantLong': order.deliveryLong, // Fallback
                  'orderId': order.id,
                  'status': status,
                });
              },
              height: 48.h,
              borderRadius: 14.r,
              color: const Color(0xF07F22FE).withOpacity(0.94),
              textStyle: const TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

