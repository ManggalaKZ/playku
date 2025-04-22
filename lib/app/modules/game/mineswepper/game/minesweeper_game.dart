import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/game/mineswepper/components/board_component.dart';
import 'package:playku/app/modules/game/mineswepper/controllers/minesweeper_controller.dart';
import 'package:playku/theme.dart';

import '../components/game_timer_component.dart';

class MinesweeperGame extends FlameGame {
  final controller = Get.find<MinesweeperController>();

  RxBool isPaused = false.obs;

  late TextComponent timerText;
  bool hasGameStarted = false;
  late GameTimerComponent gameTimer;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    controller.gameRef = this;
    add(BoardComponent());
    timerText = TextComponent(
      text: 'Waktu: 00:00',
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: TextStyle(
          color: AppColors.whitePrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(timerText);
    timerText.position = Vector2(size.x / 2, size.y * 0.15);

    gameTimer = GameTimerComponent(
      isPaused: isPaused,
      onTick: (elapsed) {
        timerText.text = 'Waktu: $elapsed';
      },
    );
    add(gameTimer);
  }

  @override
  void render(Canvas canvas) {
    final backgroundPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(size.toRect(), backgroundPaint);
    super.render(canvas);
  }

  void startGame() {
    if (hasGameStarted) return;

    timerText.text = 'Waktu: 00:00';
    isPaused.value = false;
    hasGameStarted = true;

    gameTimer.start();

    controller.isCountdownFinished.value = true;
    controller.isRestartingGame.value = false;
  }

  int getElapsedTimeInSeconds() {
    final timeText = timerText.text.replaceAll('Waktu: ', ''); 
    final parts = timeText.split(':'); 
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 0;
  }

  void endGame() {
    gameTimer.stop();
    hasGameStarted = false;
  }

  void togglePause() {
    isPaused.value = !isPaused.value;
  }

  void clearGame() {
    hasGameStarted = false;
    isPaused.value = false;
    controller.isRestartingGame.value = false;
    controller.isCountdownFinished.value = false;
    gameTimer.stop();
    remove(timerText);
    remove(gameTimer);
  }

  void mainLagi() {
    controller.resetGame();

    controller.setLevel(controller.selectedLevel.value);

    clearGame();

    add(BoardComponent());
    gameTimer.reset();
    startGame();
    add(timerText);
    add(gameTimer);
  }
}
