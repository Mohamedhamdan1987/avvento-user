import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../models/driver_order_model.dart';
import '../controllers/driver_orders_controller.dart';

class OrderDetailsBottomSheet extends StatelessWidget {
  final DriverOrderModel order;

  const OrderDetailsBottomSheet({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverOrdersController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderGray,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              
              // Order number
              Text(
                'طلب #${order.orderNumber}',
                style: const TextStyle().textColorBold(
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status.value).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _getStatusText(order.status.value),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getStatusColor(order.status.value),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              
              // Customer info
              _buildInfoSection(
                icon: Icons.person_outline,
                title: 'معلومات العميل',
                children: [
                  _buildInfoRow('الاسم', order.customerName),
                  _buildInfoRow('الهاتف', order.customerPhone),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Restaurant info
              _buildInfoSection(
                icon: Icons.restaurant_outlined,
                title: 'المطعم',
                children: [
                  _buildInfoRow('الاسم', order.restaurantName),
                  _buildInfoRow('العنوان', order.pickupLocation.address),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Delivery address
              _buildInfoSection(
                icon: Icons.location_on_outlined,
                title: 'عنوان التوصيل',
                children: [
                  _buildInfoRow('العنوان', order.deliveryLocation.address),
                  if (order.deliveryLocation.label != null)
                    _buildInfoRow('التسمية', order.deliveryLocation.label!),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Order items
              _buildInfoSection(
                icon: Icons.shopping_bag_outlined,
                title: 'تفاصيل الطلب',
                children: [
                  ...order.items.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ),
                        Text(
                          '${item.price.toStringAsFixed(2)} د.ل',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Payment info
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المجموع',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          '${order.totalAmount.toStringAsFixed(2)} د.ل',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (order.deliveryFee != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'رسوم التوصيل',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Text(
                            '${order.deliveryFee!.toStringAsFixed(2)} د.ل',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'طريقة الدفع',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          _getPaymentMethodText(order.paymentMethod),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (order.notes != null) ...[
                SizedBox(height: 16.h),
                _buildInfoSection(
                  icon: Icons.note_outlined,
                  title: 'ملاحظات',
                  children: [
                    Text(
                      order.notes!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
              
              SizedBox(height: 24.h),
              
              // Action buttons (only show for pending orders)
              if (order.status.value == 'pending') ...[
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: CustomButtonApp(
                        text: 'رفض',
                        onTap: () => controller.rejectOrder(order.id),
                        color: Colors.red,
                        isLoading: false,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: CustomButtonApp(
                        text: 'قبول الطلب',
                        onTap: () => controller.acceptOrder(order.id),
                        color: AppColors.primary,
                        isLoading: controller.isAccepting,
                      ),
                    ),
                  ],
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.r, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textMedium;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'تم القبول';
      case 'picked_up':
        return 'تم الاستلام';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'wallet':
        return 'محفظة';
      default:
        return method;
    }
  }
}
