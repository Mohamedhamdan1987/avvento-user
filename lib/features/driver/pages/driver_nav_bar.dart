import 'package:flutter/material.dart';
import '../../../core/widgets/reusable/bottom_nav_bar.dart';
import '../../../core/utils/location_utils.dart';
import '../home/pages/driver_home_page.dart';
import '../orders/pages/driver_my_orders_page.dart';
import '../wallet/pages/driver_wallet_page.dart';
import '../account/pages/driver_account_page.dart';

class DriverNavBar extends StatefulWidget {
  const DriverNavBar({super.key});

  @override
  State<DriverNavBar> createState() => _DriverNavBarState();
}

class _DriverNavBarState extends State<DriverNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DriverHomePage(),
    const DriverMyOrdersPage(),
    const DriverWalletPage(),
    const DriverAccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Request location permission when nav bar loads
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    // Wait a bit for the UI to be ready
    await Future.delayed(const Duration(milliseconds: 500));
    // Request location permission if not already granted
    if (!LocationUtils.isInitialized) {
      await LocationUtils.ensureLocationPermission();
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
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
            iconName: 'assets/svg/nav/wallet.svg',
            label: 'المحفظة',
          ),
          BottomNavItemModel(
            iconName: 'assets/svg/nav/person.svg',
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
