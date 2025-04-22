import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/game/components/select_level_dialog.dart';
import 'package:playku/app/modules/game/memory-game/controllers/memory_game_controller.dart';
import 'package:playku/core.dart';

import '../mineswepper/controllers/minesweeper_controller.dart';

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
