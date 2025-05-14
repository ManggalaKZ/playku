import 'dart:ui';
import 'dart:async' as dart_async;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/game/mineswepper/components/board_component_minesweeper.dart';
import 'package:playku/app/modules/game/mineswepper/controllers/minesweeper_controller.dart';
import 'package:playku/theme.dart';

class MinesweeperGame extends FlameGame {
  final controller = Get.find<MinesweeperController>();
  RxBool isPaused = false.obs;
  late TextComponent timerText;
  bool hasGameStarted = false;
  var elapsedTimeString = "0:00".obs;
  dart_async.Timer? _timer;
  late DateTime startTime;
  Duration totalElapsed = Duration.zero;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    controller.gameRef = this;
  }

  @override
  void render(Canvas canvas) {
    final backgroundPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(size.toRect(), backgroundPaint);
    super.render(canvas);
  }

  void startGame() {
    totalElapsed = Duration.zero;
    startTime = DateTime.now();
    if (hasGameStarted) return;
    add(BoardComponentMinesweeper());
    isPaused.value = false;
    hasGameStarted = true;
    controller.isCountdownFinished.value = true;
    controller.isRestartingGame.value = false;
    _startTimer();
  }

  void _startTimer() {
    debugPrint("Timer dimulai");
    _timer?.cancel();
    _timer = dart_async.Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused.value) {
        Duration elapsed = totalElapsed + DateTime.now().difference(startTime);
        int minutes = elapsed.inMinutes;
        int seconds = elapsed.inSeconds % 60;
        elapsedTimeString.value =
            "$minutes:${seconds.toString().padLeft(2, '0')}";
        debugPrint("waktu${elapsedTimeString.value}");
      }
    });
  }

  int convertTimeToSeconds(String lastElapsedTime) {
    List<String> parts = lastElapsedTime.split(":");
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    return (minutes * 60) + seconds;
  }

  void endGame() {
    hasGameStarted = false;
  }

  void ccTimer() {
    _timer?.cancel();
  }

  void pauseGame() {
    isPaused.value = true;
    totalElapsed += DateTime.now().difference(startTime);
    _timer?.cancel();
  }

  void resumeGame() {
    isPaused.value = false;
    startTime = DateTime.now(); // Mulai ulang dari waktu sekarang
    _startTimer();
  }

  void clearGame() {
    hasGameStarted = false;
    isPaused.value = false;
    controller.isRestartingGame.value = false;
    controller.isCountdownFinished.value = false;
    elapsedTimeString.value = "0:00";
    totalElapsed = Duration.zero;
    _timer?.cancel();
  }

  void mainLagi() {
    elapsedTimeString.value = "0:00";
    controller.isCountdownFinished.value = false;
    controller.resetGame();
    controller.setLevel(controller.selectedLevel.value);
    clearGame();
  }
}
