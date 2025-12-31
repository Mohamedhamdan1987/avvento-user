import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/reusable/bottom_nav_bar.dart';
import '../home/pages/home_page.dart';

class ClientNavBar extends StatefulWidget {
  const ClientNavBar({super.key});

  @override
  State<ClientNavBar> createState() => _ClientNavBarState();
}

class _ClientNavBarState extends State<ClientNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('طلباتي')),
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
