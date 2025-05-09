import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/widgets/dialog_exit.dart';
import 'package:playku/core.dart';


class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final exit = await Get.dialog<bool>(
          const ExitDialog(),
          barrierDismissible: false,
        );
        return exit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.whitePrimary,
        body: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 180,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
