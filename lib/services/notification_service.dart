import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService {
  static void showSuccess(String message) {
    Get.snackbar(
      'Suksesu',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Sala',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'Informasaun',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
