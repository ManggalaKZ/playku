import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/game/memory-game/views/game_over_view.dart';
import 'package:playku/app/widgets/countdown_view.dart';
import 'package:playku/theme.dart';
import '../controllers/memory_game_controller.dart';
import '../game/memory_game.dart';

class MemoryGameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MemoryGameController controller = Get.find<MemoryGameController>();
    final MemoryGame game = Get.find<MemoryGame>();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'GameOver': (context, game) =>
                    GameOverScreen(game as MemoryGame),
              },
            ),
            Obx(() {
              if (!controller.isCountdownFinished.value ||
                  controller.isRestartingGame.value) {
                return CountdownView(onCountdownFinished: controller.startGame);
              }
              return SizedBox();
            }),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: EdgeInsets.all(8),
                child: Obx(() => Text(
                      "Waktu: ${controller.elapsedTime.value} detik",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () {
                  AudioService.playButtonSound();
                  controller.pauseGame();
                },
              ),
            ),
            Obx(() {
              if (controller.isPaused.value) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: const Color.fromARGB(159, 0, 0, 0),
                  child: Center(
                    child: Container(
                      height: 250,
                      width: 320,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Game Paused",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              AudioService.playButtonSound();
                              controller.resumeGame();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Text("Resume",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              AudioService.playButtonSound();
                              controller.stopTimer();
                              controller.exitGame();
                              controller.isPaused.value = false;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Text("Keluar",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
