import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();

    return Obx(() {
      bool isObscure = obscureText ? !loginController.isPasswordVisible.value : loginController.dummyTrigger.value;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            hintText: hintText,
            
            hintStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            border: InputBorder.none,
            suffixIcon: obscureText
                ? IconButton(
                    icon: Icon(
                      loginController.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      loginController.isPasswordVisible.toggle();
                    },
                  )
                : null,
          ),
        ),
      );
    });
  }
}




