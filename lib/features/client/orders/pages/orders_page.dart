import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'order_details_screen.dart';
import '../widgets/order_card.dart';
import '../widgets/current_order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedTab = 0; // 0 = السابقة, 1 = جاري التنفيذ

  // Sample data - replace with actual data from your API
  final List<Map<String, dynamic>> _previousOrders = [
    {
      'id': '855',
      'restaurantName': 'بيتزا هت',
      'restaurantImage': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200',
      'status': 'completed',
      'items': 'بيتزا بيبروني كبيرة',
      'price': '35.00',
    },
    {
      'id': '742',
      'restaurantName': 'كنتاكي',
      'restaurantImage': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200',
      'status': 'cancelled',
      'items': 'بوكس مايتي زنجر',
      'price': '28.00',
    },
  ];

  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': '8291',
      'restaurantName': 'بيتزا هت',
      'restaurantImage': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200',
      'status': 'pendingAcceptance',
      'items': 'بيتزا بيبروني وسط، بيبسي، بطاطس ودجز',
      'price': '25.5',
      'estimatedTime': '12:45 م',
      'timeRemaining': '15-20 دقيقة',
    },
    {
      'id': '8292',
      'restaurantName': 'برجر كينج',
      'restaurantImage': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
      'status': 'confirmed',
      'items': 'برجر دبل، بطاطس، بيبسي',
      'price': '30.0',
      'estimatedTime': '12:50 م',
      'timeRemaining': '20-25 دقيقة',
    },
    {
      'id': '8293',
      'restaurantName': 'كنتاكي',
      'restaurantImage': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200',
      'status': 'preparing',
      'items': 'بوكس مايتي زنجر، بطاطس، بيبسي',
      'price': '28.0',
      'estimatedTime': '01:00 م',
      'timeRemaining': '10-15 دقيقة',
    },
    {
      'id': '8294',
      'restaurantName': 'ماكدونالدز',
      'restaurantImage': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=200',
      'status': 'onTheWay',
      'items': 'بيج ماك، بطاطس، كوكاكولا',
      'price': '22.5',
      'estimatedTime': '01:05 م',
      'timeRemaining': '5-10 دقيقة',
    },
    {
      'id': '8295',
      'restaurantName': 'بيتزا هت',
      'restaurantImage': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200',
      'status': 'waitingPickup',
      'items': 'بيتزا مارغريتا كبيرة',
      'price': '35.0',
      'estimatedTime': '01:10 م',
      'timeRemaining': 'الكابتن بالخارج',
    },
    {
      'id': '8296',
      'restaurantName': 'دومينوز',
      'restaurantImage': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200',
      'status': 'delivered',
      'items': 'بيتزا بيبروني وسط، بيبسي',
      'price': '27.5',
      'estimatedTime': '01:15 م',
      'timeRemaining': 'تم التسليم',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context),
            
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab Switcher
                      _buildTabSwitcher(),
                      
                      SizedBox(height: 16.h),
                      
                      // Orders List
                      if (_selectedTab == 1)
                        ..._previousOrders.map((order) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: PreviousOrderCard(
                                order: order,
                                onTap: () {
                                  // Navigate to order details if needed
                                },
                              ),
                            ))
                      else
                        ..._activeOrders.map((order) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsScreen(order: order),
                                    ),
                                  );
                                },
                                child: CurrentOrderCard(
                                  order: order,
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 82.h,
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Color(0xFF101828),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // Active Tab Background
          AnimatedPositionedDirectional(
            duration: Duration(milliseconds: 200),
            start: _selectedTab == 0 ? 4.w : null,
            end: _selectedTab == 1 ? 4.w : null,
            top: 4.h,
            child: Container(
              width: 168.38.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(0, 1),
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
                    height: 40.h,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                       spacing: 8.w,
                      children: [
                        Text(
                          'جاري التنفيذ',
                          style: TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color: _selectedTab == 0
                                ? Color(0xFF101828)
                                : Color(0xFF6A7282),
                          ),
                        ),
                        Container(
                          width: 18.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFFB2C36),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_activeOrders.length}',
                              style: TextStyle().textColorBold(
                                fontSize: 10.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
                    // height: 40.h,
                    alignment: Alignment.center,
                    child: Text(
                      'السابقة',
                      style: TextStyle().textColorBold(
                        fontSize: 14.sp,
                        color: _selectedTab == 1
                            ? Color(0xFF101828)
                            : Color(0xFF6A7282),
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

