import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/modules/game/answer-question/component/pause_component.dart';
import 'package:playku/app/widgets/dialog_exit_game.dart';
import 'package:playku/core.dart';

class AnswerQuestionView extends StatefulWidget {
  @override
  _AnswerQuestionViewState createState() => _AnswerQuestionViewState();
}

class _AnswerQuestionViewState extends State<AnswerQuestionView> {
  final AnswerQuestionGame game = AnswerQuestionGame();

  void _startGame() {
    debugPrint("Countdown selesai! Game dimulai...");
    setState(() {
      game.controller.isCountdownFinished.value = true;
    });
    game.startGame();
  }

  void _pauseGame() {
    setState(() {
      game.controller.isPaused = true;
    });
    game.pauseGame();
    game.pauseEngine();
  }

  void _resumeGame() {
    setState(() {
      game.controller.isPaused = false;
    });
    game.resumeGame();
    game.resumeEngine();
  }

  void _exitGame() {
    AudioService.playButtonSound();
    Get.offAllNamed(Routes.HOME);
    Future.delayed(const Duration(milliseconds: 300), () {
      game.exitGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final exit = await Get.dialog<bool>(
          ExitDialogGame(onExit: _exitGame),
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
                'GameOver': (context, game) =>
                    GameOverScreen(game as AnswerQuestionGame),
              },
            ),
            if (!game.controller.isCountdownFinished.value)
              CountdownView(onCountdownFinished: _startGame),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: _pauseGame,
              ),
            ),
            if (!game.controller.isPaused &&
                game.controller.isCountdownFinished.value)
              Align(
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
                      game.controller.elapsedTimeString.value,
                      style: GoogleFonts.sawarabiGothic(
                          fontSize: 28, color: Colors.white),
                    );
                  }),
                ),
              ),
            if (game.controller.isPaused)
              PauseOverlay(
                waktu: game.controller.elapsedTimeString.value,
                namaGame: "Math Metrix",
                onResume: () {
                  AudioService.playButtonSound();
                  _resumeGame();
                },
                onRestart: () {
                  AudioService.playButtonSound();
                  game.controller.isCountdownFinished.value = false;
                  game.restartGame();
                  game.overlays.remove('GameOver');

                  // Tutup semua overlay & jadwalkan navigasi di frame berikutnya
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.offAll(() => AnswerQuestionView());
                  });
                },
                onExit: _exitGame,
              ),
          ],
        ),
      ),
    );
  }
}
