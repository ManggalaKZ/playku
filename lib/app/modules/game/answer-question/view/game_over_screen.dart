import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/core.dart';

class GameOverScreen extends StatelessWidget {
  final AnswerQuestionGame game;

  const GameOverScreen(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: const Color.fromARGB(159, 0, 0, 0),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Get.width * 0.72,
                margin: const EdgeInsets.only(top: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Math Metrix\n${game.controller.correctAnswers}/10',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 28.0,
                          color: Colors.white,
                        ),
                        Text(
                          ' +5',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height:
                          120.0, // tambahkan tinggi agar ada ruang teks di bawah
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  AudioService.playButtonSound();
                                  game.controller.isCountdownFinished.value =
                                      false;
                                  game.restartGame();
                                  game.overlays.remove('GameOver');

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    Get.offAll(() => AnswerQuestionView());
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/icons/restart.svg',
                                  height: 60,
                                  // color: AppColors.whitePrimary,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Main Lagi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.offAllNamed(Routes.HOME);
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    game.exitGame();
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/icons/leave.svg',
                                  height: 60,
                                  // color: AppColors.whitePrimary,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Keluar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/bg/bingkai.svg',
                      width: 100,
                      height: 100,
                    ),
                    // ArcText di tengah bingkai
                    Positioned(
                      top: 20, // atur agar pas di tengah bingkai
                      child: Text(
                        "MENANG",
                        style: GoogleFonts.sawarabiGothic(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black45,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ), // teks di dalam lingkaran
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
