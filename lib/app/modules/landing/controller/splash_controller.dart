import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core/core.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    debugPrint("Splash Screen dijalankan");
    super.onInit();
    navigateToNextPage();
  }

  void navigateToNextPage() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      var userData = await SharedPreferenceHelper.getUserData();

      if (userData != null) {
        debugPrint("User ditemukan: ${userData['username']}");
        Get.offNamed(Routes.HOME);
      } else {
        debugPrint("User tidak ditemukan, ke WelcomeView");
        Get.offNamed(Routes.WELCOME);
      }
    } catch (e, stack) {
      debugPrint("❌ Terjadi error di SplashController: $e");
      debugPrint(stack as String?);
      Get.offNamed(Routes.WELCOME); // fallback
    }
  }
}
