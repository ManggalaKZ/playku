import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:playku/core.dart';


class AnswerQuestionView extends StatefulWidget {
  @override
  _AnswerQuestionViewState createState() => _AnswerQuestionViewState();
}

class _AnswerQuestionViewState extends State<AnswerQuestionView> {
  final AnswerQuestionGame game = AnswerQuestionGame();
  bool _isCountdownFinished = false;
  bool _isPaused = false;

  void _startGame() {
    print("Countdown selesai! Game dimulai...");
    setState(() {
      _isCountdownFinished = true;
    });
    game.startGame();
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    game.pauseGame();
    game.pauseEngine();
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    game.resumeGame();
    game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, game) =>
                  GameOverScreen(game as AnswerQuestionGame),
              // 'GameOver': (context, game) =>
              //     GameOverScreen(game as AnswerQuestionGame),
            },
          ),
          if (!_isCountdownFinished)
            CountdownView(onCountdownFinished: _startGame),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: _pauseGame,
            ),
          ),
          Obx(() {
            return Positioned(
                top: 50,
                left: 20,
                child: Text("${game.elapsedTimeString.value}"));
          }),
          if (_isPaused)
            Container(
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
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: () {
                            AudioService.playButtonSound();
                            _resumeGame();
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: () {
                            AudioService.playButtonSound();
                            game.exitGame();
                            Get.back();
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
