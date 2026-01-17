import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/features/client/orders/controllers/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'order_details_screen.dart';
import '../widgets/order_card.dart';
import '../widgets/current_order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedTab = 0; // 0 = جاري التنفيذ, 1 = السابقة

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildTabSwitcher(context),
            ),

            // Content Section
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && 
                    controller.activeOrders.isEmpty && 
                    controller.previousOrders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentList = _selectedTab == 0 ? controller.activeOrders : controller.previousOrders;

                return RefreshIndicator(
                  onRefresh: controller.refreshOrders,
                  child: currentList.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          final order = currentList[index];
                          
                          if (_selectedTab == 1) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: PreviousOrderCard(
                                order: order,
                                onTap: () {
                                  // Navigate to details if needed
                                },
                              ),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => OrderDetailsScreen(order: order));
                                },
                                child: CurrentOrderCard(
                                  order: order,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80.r, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'لا توجد طلبات حالياً',
            style: const TextStyle().textColorBold(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 82.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Text(
            'طلباتي',
            style: TextStyle().textColorBold(
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher(BuildContext context) {
    final controller = Get.find<OrdersController>();
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // Active Tab Background
          AnimatedPositionedDirectional(
            duration: const Duration(milliseconds: 200),
            start: _selectedTab == 0 ? 4.w : null,
            end: _selectedTab == 1 ? 4.w : null,
            top: 4.h,
            child: Container(
              width: 168.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // Tabs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 0;
                    });
                  },
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'جاري التنفيذ',
                          style: const TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color: _selectedTab == 0
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        if (controller.activeOrders.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFB2C36),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${controller.activeOrders.length}',
                                style: const TextStyle().textColorBold(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    )),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 1;
                    });
                  },
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text(
                      'السابقة',
                      style: const TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: _selectedTab == 1
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

