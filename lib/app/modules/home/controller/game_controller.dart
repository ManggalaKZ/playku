import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/game/memory-game/controllers/memory_game_controller.dart';
import 'package:playku/core.dart';
import 'package:playku/theme.dart';

import '../../game/mineswepper/controllers/minesweeper_controller.dart';

class GameController extends GetxController {
  var countdown = 3.obs;
  var isCountingDown = false.obs;
  int idgame = 0;
  var selectedLevel = GameLevel.easy.obs;
  MemoryGameController controller = Get.put(MemoryGameController());
  MinesweeperController minesweeperController =
      Get.put(MinesweeperController());

  Future<void> startCountdown(Function onComplete) async {
    isCountingDown.value = true;
    for (int i = 3; i >= 0; i--) {
      countdown.value = i;
      await Future.delayed(const Duration(seconds: 1));
    }
    isCountingDown.value = false;
    onComplete();
  }

  void playGame(int indexGame) {
    print("Index game yang dipilih: $indexGame");
    switch (indexGame) {
      case 0:
        idgame = 0;
        Get.toNamed('/answer-question');
        break;
      case 1:
        idgame = 1;
        Get.toNamed('/memory-game');
        break;
      case 2:
        idgame = 2;
        Get.toNamed('/minesweeper');
        break;
      default:
        print("Game tidak tersedia");
        break;
    }
  }

  void showDialogConfirm(BuildContext context, int indexGame, String title) {
    AudioService.playButtonSound();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sawarabiGothic(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Pilih Level",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Column(
                        children: GameLevel.values.map((level) {
                          bool isSelected =
                              controller.selectedLevel.value == level;

                          return GestureDetector(
                            onTap: () {
                              controller.selectedLevel.value = level;
                              minesweeperController.selectedLevel.value = level;
                              selectedLevel.value = level;
                              AudioService.playButtonSound();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.whitePrimary
                                      : Colors.white24,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? AppColors.secondary.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text(
                                  level.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          AudioService.playButtonSound();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                              fontSize: 16, color: AppColors.whitePrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          AudioService.playButtonSound();
                          Navigator.of(context).pop();
                          controller.setLevel();
                          playGame(indexGame);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whitePrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Mainkan",
                          style:
                              TextStyle(fontSize: 16, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
