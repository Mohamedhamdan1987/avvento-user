import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/controllers/driver_orders_controller.dart';
import '../widgets/driver_performance_card.dart';
import '../widgets/driver_earnings_summary_card.dart';
import '../widgets/driver_recent_activity_item.dart';

class DriverMyOrdersPage extends StatefulWidget {
  const DriverMyOrdersPage({super.key});

  @override
  State<DriverMyOrdersPage> createState() => _DriverMyOrdersPageState();
}

class _DriverMyOrdersPageState extends State<DriverMyOrdersPage> {
  String _selectedPeriod = 'أسبوعي'; // يومي, أسبوعي, شهري

  @override
  void initState() {
    super.initState();
    _initializeController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  void _initializeController() {
    if (!Get.isRegistered<DriverOrdersController>()) {
      Get.put(DriverOrdersController());
    }
  }

  Future<void> _fetchOrders() async {
    final controller = Get.find<DriverOrdersController>();
    await Future.wait([
      controller.fetchMyOrders(),
      controller.fetchDashboardData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AppRefreshIndicator(
          onRefresh: _fetchOrders,
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),

              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      // Performance Card
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                        child: const DriverPerformanceCard(),
                      ),
                      SizedBox(height: 24.h),

                      // Earnings Summary Card
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                        child: DriverEarningsSummaryCard(
                          selectedPeriod: _selectedPeriod,
                          onPeriodChanged: (period) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Latest Activities Section
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                        child: _buildLatestActivitiesSection(),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 16.w,
        end: 16.w,
        top: 48.h,
        bottom: 0,
      ),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title "أداء التوصيل" on the right (in RTL, right = start)
              Text(
                'أداء التوصيل',
                style: const TextStyle().textColorBold(
                  fontSize: 24.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),

              // Profile picture on the left (in RTL, left = end)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).cardColor,
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.r),
                      child: Image.asset(
                        'assets/avvento.PNG',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 24.r,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Online status indicator - positioned at bottom end (right in RTL)
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C950),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 1.5.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildLatestActivitiesSection() {
    return GetX<DriverOrdersController>(
      builder: (controller) {
        final dashboard = controller.dashboardData;
        final activities = dashboard?.recentActivities ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'آخر النشاطات',
              style: const TextStyle().textColorBold(
                fontSize: 18.sp,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 16.h),

            // Activities List
            if (activities.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 60.r,
                        color: AppColors.textPlaceholder,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد نشاطات حديثة',
                        style: const TextStyle().textColorNormal(
                          fontSize: 14.sp,
                          color: AppColors.textPlaceholder,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activities.take(10).map((order) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: DriverRecentActivityItem(order: order),
                );
              }).toList(),
          ],
        );
      },
    );
  }
}