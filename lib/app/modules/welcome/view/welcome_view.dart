import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/theme.dart';
import '../../../data/services/audio_service.dart';
import '../controller/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "MAINKAN, TANTANG MENANGKAN!",
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 34,
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/images/logo.png',
                        width: 240,
                      ),
                      const SizedBox(height: 50),
                      Text(
                        '"Selamat datang di PlayKu! Nikmati berbagai game seru dalam satu aplikasi. Kumpulkan poin, tantang diri, dan jadilah yang terbaik!"',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.sawarabiGothic(
                          fontSize: 17,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 400,
                        child: ElevatedButton(
                          onPressed: () {
                            AudioService.playButtonSound();
                            controller.goToLogin();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "MULAI!",
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 17.5,
                              color: AppColors.whitePrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
