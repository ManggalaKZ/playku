import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/modules/auth/components/form_login.dart';
import 'package:playku/app/modules/auth/controller/login_controller.dart';
import 'package:playku/app/routes/app_routes.dart';
import 'package:playku/app/widgets/languange_switch.dart';
import 'package:playku/app/widgets/sound_button.dart';
import 'package:playku/theme.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/bg/hiasan.svg',
              height: 200,
              color: AppColors.whitePrimary,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.27),
                  Container(
                    padding: const EdgeInsets.all(24),
                    height: MediaQuery.of(context).size.height * 0.53,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SoundButton(controller: controller),
                            // LanguangeSwitch(controller: controller),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Login!",
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 58,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: "Email atau username",
                          controller: controller.usernameController,
                        ),
                        CustomTextField(
                          hintText: "Password",
                          controller: controller.passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 25),
                        Container(
                          color: AppColors.whitePrimary,
                          width: 400,
                          child: Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.login(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  disabledBackgroundColor: AppColors.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Container(
                                  height: 45,
                                  padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: controller.isLoading.value
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                            backgroundColor:
                                                AppColors.secondary,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            "Masuk",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.luckiestGuy(
                                              fontSize: 17.5,
                                              color: AppColors.whitePrimary,
                                            ),
                                          ),
                                        ),
                                ),
                              )),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun? ",
                              style: GoogleFonts.sawarabiGothic(fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.offAllNamed(Routes.REGISTRASI);
                              },
                              child: Text(
                                "Daftar di sini",
                                style: GoogleFonts.sawarabiGothic(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                    ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
