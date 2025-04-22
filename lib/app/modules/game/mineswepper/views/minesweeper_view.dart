import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/game/mineswepper/views/gameOver_view.dart';
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

    return Scaffold(
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
                game.togglePause();
              },
            ),
          ),
          Obx(() {
            if (game.isPaused.value) {
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
                            game.togglePause(); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            "Resume",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            AudioService.playButtonSound();
                            Get.back();
                            controller.resetGame();
                            game.gameTimer.reset();
                            await Future.delayed(Duration(milliseconds: 1200));
                            game.clearGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            "Keluar",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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
    );
  }
}
