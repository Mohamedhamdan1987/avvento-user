import 'package:flutter/material.dart';
import '../../../core/widgets/reusable/bottom_nav_bar.dart';
import '../home/pages/home_page.dart';
import '../orders/pages/orders_page.dart';
import '../cart/pages/cart_list_page.dart';
import '../cart/controllers/cart_controller.dart';
import '../account/pages/account_page.dart';
import 'package:get/get.dart';

class ClientNavBar extends StatefulWidget {
  const ClientNavBar({super.key});

  @override
  State<ClientNavBar> createState() => _ClientNavBarState();
}

class _ClientNavBarState extends State<ClientNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OrdersPage(),
    const CartListPage(),
    const AccountPage(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().fetchAllCarts();
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
