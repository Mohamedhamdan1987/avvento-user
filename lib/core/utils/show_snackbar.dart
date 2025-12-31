import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

showSnackBar({required String message, String? title ,  Color? bgColor}) {
  Get.snackbar(
    title?? 'تنبيه',
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.white,
  );
}