import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/modules/game/answer-question/component/pause_component.dart';
import 'package:playku/app/modules/game/mineswepper/views/gameOver_view.dart';
import 'package:playku/app/widgets/dialog_exit_game.dart';
import 'package:playku/core.dart';

class MinesweeperView extends StatelessWidget {
  const MinesweeperView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MinesweeperGame game = Get.put(MinesweeperGame());
    final controller = Get.find<MinesweeperController>();

    controller.onGameEndCallback = (won) {
      final overlay = won ? 'GameWinOverlay' : 'GameOverOverlay';
      controller.gameRef?.overlays.add(overlay);
      game.endGame();
    };

    controller.setLevel(controller.selectedLevel.value);

    return WillPopScope(
      onWillPop: () async {
        final exit = await Get.dialog<bool>(
          ExitDialogGame(
            onExit: () async {
              AudioService.playButtonSound();

              controller.resetGame();
              // game.gameTimer.reset();
              await Future.delayed(Duration(milliseconds: 1200));
              game.clearGame();
              Get.offAllNamed(Routes.HOME);
            },
          ),
          barrierDismissible: false,
        );
        return exit ?? false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'GameOverOverlay': (_, __) => GameOverScreenMinesweeper(),
                'GameWinOverlay': (_, __) => GameWinScreen(),
              },
            ),
            Obx(() {
              if (!controller.isCountdownFinished.value ||
                  controller.isRestartingGame.value) {
                return CountdownView(onCountdownFinished: game.startGame);
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
                  game.pauseGame();
                },
              ),
            ),
            Obx(() {
              if (!game.isPaused.value &&
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
                        game.elapsedTimeString.value,
                        style: GoogleFonts.sawarabiGothic(
                            fontSize: 28, color: Colors.white),
                      );
                    }),
                  ),
                );
              }
              return SizedBox();
            }),
            Obx(() {
              if (game.isPaused.value) {
                return PauseOverlay(
                  waktu: "${game.elapsedTimeString.value}",
                  namaGame: "MineSweeper",
                  onResume: () {
                    AudioService.playButtonSound();
                    game.resumeGame();
                  },
                  onRestart: () {
                    controller.gameRef?.overlays.remove('GameWinOverlay');
                    game.elapsedTimeString.value = "0:00";
                    game.mainLagi();
                  },
                  onExit: () async {
                    AudioService.playButtonSound();

                    controller.resetGame();
                    // game.gameTimer.reset();
                    await Future.delayed(Duration(milliseconds: 1200));
                    game.clearGame();
                    Get.offAllNamed(Routes.HOME);
                  },
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
