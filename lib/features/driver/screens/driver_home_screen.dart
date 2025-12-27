import 'package:flutter/material.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية - السائق'),
      ),
      body: const Center(
        child: Text('مرحباً بك في صفحة السائق'),
      ),
    );
  }
}

