import 'package:flutter/material.dart';
import 'package:get/get.dart';

showSnackBar({
  required String message,
  String? title,
  Color? bgColor,
  bool isError = false,
  bool isSuccess = false,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title ?? (isError ? 'خطأ' : isSuccess ? 'نجاح' : 'تنبيه'),
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError
          ? Colors.red.shade50
          : isSuccess
              ? Colors.green.shade50
              : Colors.white,
      colorText: isError
          ? Colors.red
          : isSuccess
              ? Colors.green
              : Colors.black,
      icon: isError
          ? const Icon(Icons.error_outline, color: Colors.red)
          : isSuccess
              ? const Icon(Icons.check_circle_outline, color: Colors.green)
              : null,
    );
  });
}