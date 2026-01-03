import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

showSnackBar({required String message, String? title, Color? bgColor, bool isError = false}) {
  Get.snackbar(
    title ?? 'تنبيه',
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red.shade50 : Colors.white,
    colorText: isError ? Colors.red : Colors.black,
  );
}