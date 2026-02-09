import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/features/client/orders/controllers/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'order_details_screen.dart';
import '../widgets/previous_order_card.dart';
import '../widgets/current_order_card.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'طلبات'),
      body: DefaultTabController(
        length: 2,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Header Section
              // _buildHeaderSection(context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildTabSwitcher(context),
              ),

              // Content Section
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOrdersList(context, controller, isPrevious: false),
                    _buildOrdersList(context, controller, isPrevious: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.r,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد طلبات حالياً',
            style: const TextStyle().textColorBold(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
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
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(4.w),
        indicator: BoxDecoration(
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
        labelColor: Theme.of(context).textTheme.bodyLarge?.color,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          fontFamily:
              'Cairo', // Assuming Cairo is the app font, otherwise rely on default
        ),
        tabs: [
          Tab(
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('جاري التنفيذ'),
                  if (controller.activeOrders.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
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
              ),
            ),
          ),
          const Tab(text: 'السابقة'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    OrdersController controller, {
    required bool isPrevious,
  }) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.activeOrders.isEmpty &&
          controller.previousOrders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final currentList = isPrevious
          ? controller.previousOrders
          : controller.activeOrders;

      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        child: currentList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final order = currentList[index];

                  if (isPrevious) {
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
                        child: CurrentOrderCard(order: order),
                      ),
                    );
                  }
                },
              ),
      );
    });
  }
}
