import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/theme.dart';
import '../modules/auth/controller/login_controller.dart';

class LanguangeSwitch extends StatelessWidget {
  final LoginController controller;

  const LanguangeSwitch({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: controller.toggleLanguage,
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "EN",
                      style: TextStyle(
                        color: controller.isEnglish.value
                            ? AppColors.primary
                            : AppColors.whitePrimary, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID",
                      style: TextStyle(
                        color: controller.isEnglish.value
                            ? AppColors.whitePrimary
                            : AppColors.primary, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: controller.isEnglish.value
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.isEnglish.value ? "EN" : "ID",
                      style: const TextStyle(
                        color: AppColors.whitePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
