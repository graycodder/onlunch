import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  void openCustomerSupport() async {
    final uri = Uri.parse('tel:+919995226139');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Customer Support',
        'Call us at +91 99952 26139',
        backgroundColor: Colors.white,
        colorText: const Color(0xFF075B25),
      );
    }
  }

  void showInfoDialog(String title, String content) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF153B22)),
      middleText: content,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF075B25),
      onConfirm: () => Get.back(),
    );
  }

  void confirmLogout() {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF153B22)),
      middleText: 'Are you sure you want to log out of OneLunch?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF075B25),
      cancelTextColor: const Color(0xFF153B22),
      onConfirm: () {
        Get.back();
        authController.logout();
      },
    );
  }

  void navigateToOrders() {
    Get.toNamed(AppRoutes.myOrders);
  }
}

