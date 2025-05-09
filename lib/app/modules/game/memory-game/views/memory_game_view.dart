import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/game/answer-question/component/pause_component.dart';
import 'package:playku/app/modules/game/memory-game/views/game_over_view.dart';
import 'package:playku/app/widgets/countdown_view.dart';
import 'package:playku/app/widgets/dialog_exit_game.dart';
import 'package:playku/theme.dart';
import '../controllers/memory_game_controller.dart';
import '../game/memory_game.dart';

class MemoryGameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MemoryGameController controller = Get.find<MemoryGameController>();
    final MemoryGame game = Get.find<MemoryGame>();
    return WillPopScope(
      onWillPop: () async {
        final exit = await Get.dialog<bool>(
          ExitDialogGame(
            onExit: () async {
              AudioService.playButtonSound();
              controller.stopTimer();
              controller.exitGame();
              controller.isPaused.value = false;
            },
          ),
          barrierDismissible: false,
        );
        return exit ?? false;
      },
      child: Scaffold(
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
                  return CountdownView(
                      onCountdownFinished: controller.startGame);
                }
                return SizedBox();
              }),
              Obx(() {
                if (!game.controller.isPaused.value &&
                    game.controller.isCountdownFinished.value) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                      margin: EdgeInsets.only(top: Get.height * 0.1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.5),
                      ),
                      child: Obx(() {
                        return Text(
                          controller.elapsedTimeString.value,
                          style: GoogleFonts.sawarabiGothic(
                              fontSize: 28, color: Colors.white),
                        );
                      }),
                    ),
                  );
                }
                return SizedBox();
              }),
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
                  return PauseOverlay(
                    waktu: "${controller.elapsedTimeString.value}",
                    namaGame: "Memory Game",
                    onResume: () {
                      AudioService.playButtonSound();
                      controller.resumeGame();
                    },
                    onRestart: () {
                      AudioService.playButtonSound();
                      game.controller.mainlagi();
                      controller.isPaused.value = false;
                      game.overlays.remove('GameOver');
                    },
                    onExit: () {
                      AudioService.playButtonSound();
                      controller.stopTimer();
                      controller.exitGame();
                      controller.isPaused.value = false;
                    },
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
