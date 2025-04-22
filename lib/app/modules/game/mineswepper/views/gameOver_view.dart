import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/game/mineswepper/components/board_component.dart';
import 'package:playku/app/modules/game/mineswepper/controllers/minesweeper_controller.dart';
import 'package:playku/app/modules/game/mineswepper/game/minesweeper_game.dart';

import 'minesweeper_view.dart';

class GameOverScreen extends StatelessWidget {
  final game = Get.find<MinesweeperGame>();
  final controller = Get.find<MinesweeperController>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('Game Over'),
        content:
            Text('Kamu menginjak bom! 😢 \n lastime ${controller.lastTime}'),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              controller.resetGame();
              game.gameTimer.reset();
              await Future.delayed(Duration(milliseconds: 1200));
              game.clearGame();
            },
            child: Text('Keluar'),
          ),
          TextButton(
            onPressed: () {
              controller.gameRef?.overlays.remove('GameOverOverlay');
              game.mainLagi();
            },
            child: Text('Main Lagi'),
          ),
        ],
      ),
    );
  }
}
