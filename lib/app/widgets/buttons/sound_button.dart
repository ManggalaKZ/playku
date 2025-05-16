import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../modules/auth/controller/login_controller.dart';


class SoundButton extends StatelessWidget {
  final LoginController controller;
  final color;
  
  const SoundButton({super.key, required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: controller.toggleSound,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0.2,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              color: color,
              controller.isSoundOn.value
                  ? 'assets/icons/suara_on.svg'
                  : 'assets/icons/suara_off.svg',
              height: 30,
            ),
          ),
        ));
  }
}
