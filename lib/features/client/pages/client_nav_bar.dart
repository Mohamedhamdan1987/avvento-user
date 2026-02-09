import 'package:flutter/material.dart';
import '../../../core/widgets/reusable/bottom_nav_bar.dart';
import '../home/pages/home_page.dart';
import '../orders/pages/orders_page.dart';
import '../cart/pages/cart_list_page.dart';
import '../cart/controllers/cart_controller.dart';
import '../account/pages/account_page.dart';
import 'package:get/get.dart';
import 'controllers/client_nav_bar_controller.dart';

class ClientNavBar extends StatefulWidget {
  const ClientNavBar({super.key});

  @override
  State<ClientNavBar> createState() => _ClientNavBarState();
}

class _ClientNavBarState extends State<ClientNavBar> {
  final List<Widget> _pages = [
    const HomePage(),
    const OrdersPage(),
    const CartListPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['tabIndex'] != null) {
      final controller = Get.find<ClientNavBarController>();
      controller.setIndex(args['tabIndex'] as int);
    }
  }

  void _onTap(int index) {
    if (index == 2) {
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().fetchAllCarts();
      }
    }
    Get.find<ClientNavBarController>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientNavBarController>();
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: _onTap,
          navItems: [
            BottomNavItemModel(
              iconName: 'assets/svg/nav/home.svg',
              label: 'الرئيسية',
            ),
            BottomNavItemModel(
              iconName: 'assets/svg/nav/list.svg',
              label: 'طلباتي',
            ),
            BottomNavItemModel(
              iconName: 'assets/svg/nav/cart.svg',
              label: 'السلة',
            ),
            BottomNavItemModel(
              iconName: 'assets/svg/nav/person.svg',
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
