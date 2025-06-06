import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core/core.dart';
import 'package:playku/core/core_game.dart';

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
    debugPrint("Index game yang dipilih: $indexGame");
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
        debugPrint("Game tidak tersedia");
        break;
    }
  }

  void showDialogConfirm(BuildContext context, int indexGame, String title) {
    AudioService.playButtonSound();

    showDialog(
      context: context,
      builder: (context) {
        return SelectLevelDialog(
          indexGame: indexGame,
          title: title,
          selectedLevel: selectedLevel,
          onLevelSelected: (level) {
            controller.selectedLevel.value = level;
            minesweeperController.selectedLevel.value = level;
          },
          onPlay: (index) {
            controller.setLevel();
            playGame(index);
          },
        );
      },
    );
  }
}
