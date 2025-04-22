import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/theme.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitePrimary,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 180,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
