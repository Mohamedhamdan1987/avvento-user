import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/reusable/bottom_nav_bar.dart';

class DriverNavBar extends StatefulWidget {
  const DriverNavBar({super.key});

  @override
  State<DriverNavBar> createState() => _DriverNavBarState();
}

class _DriverNavBarState extends State<DriverNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('الرئيسية (سائق)')),
    const Center(child: Text('طلبات التوصيل')),
    const Center(child: Text('المحفظة')),
    const Center(child: Text('حسابي')),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
