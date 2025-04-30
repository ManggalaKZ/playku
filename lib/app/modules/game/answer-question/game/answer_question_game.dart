import 'dart:async';
import 'dart:convert';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/dialog_new_leaderboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:playku/core.dart';
import 'package:playku/app/modules/game/answer-question/controller/answer_question_controller.dart';

class AnswerQuestionGame extends FlameGame with TapDetector {
  final AnswerQuestionController controller =
      Get.put(AnswerQuestionController());
  GameController gamecontroller = Get.put(GameController());
  AnswerQuestionGame() {
    debugMode = true;
  }
  late QuestionComponent questionComponent;
  late List<AnswerComponent> answerComponents;
  var userModel = Rxn<UserModel>();
  String level = "eazy";
  int currentQuestion = 1;
  int correctAnswers = 0;
  late DateTime _startTime;
  var elapsedTimeString = "0:00".obs;
  Timer? _timer;
  bool _isPaused = false;
  var leaderboard = <Leaderboard>[].obs;

  String lastElapsedTime = "";

  @override
  Future<void> onLoad() async {
    controller.loadUserFromPrefs();
    controller.startTime = DateTime.now();
  }

  @override
  Color backgroundColor() => AppColors.primary;

  @override
  void onTapUp(TapUpInfo event) {
    super.onTapUp(event);
    Vector2 tapPosition = event.eventPosition.global;
    for (var answer in answerComponents) {
      if (answer.containsPoint(tapPosition)) {
        answer.onPressed(answer.isCorrect);
        break;
      }
    }
  }

  void startGame() {
    controller.startGame();
    _generateNewQuestion();
    overlays.remove('Countdown');
  }

  void pauseGame() {
    controller.pauseGame();
  }

  void resumeGame() {
    controller.resumeGame();
  }

  void stopTimer() {
    controller.stopTimer();
  }

  void gameOver() async {
    stopTimer();
    GameController gc = Get.put(GameController());
    int finalTime =
        controller.convertTimeToSeconds(controller.elapsedTimeString.value);
    int finalScore = controller.correctAnswers.value;
    String userId = controller.userModel.value!.id ?? "";
    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String levels =
        gamecontroller.selectedLevel.value.toString().split('.').last;
    controller.loadLeaderboard(gc.idgame, levels);

    GameService.postGameResult(
      userId: userId,
      gameId: gc.idgame,
      score: finalScore,
      timePlay: finalTime,
      level: levels,
      playedAt: now,
    ).then((success) async {
      if (success) {
        controller.lastElapsedTime = "00:00";
        int? newPoint = await PointService.updateUserPoint(userId, 5);
        if (newPoint != null) {
          controller.userModel.value =
              controller.userModel.value!.copyWith(point: newPoint);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(
              'user', jsonEncode(controller.userModel.value!.toJson()));
          HomeController homeController = Get.find<HomeController>();
          homeController.userController.loadUserFromPrefs();
          homeController.userController.userModel.refresh();
          homeController.leaderboardController.loadLeaderboard();
        }
      }
    });

    Leaderboard entry = Leaderboard(
        userId: userId,
        gameId: gc.idgame,
        score: finalScore,
        timePlay: finalTime,
        played_at: now,
        level: levels);

    await Future.delayed(Duration(milliseconds: 1));
    if (finalScore == 10) {
      controller.addScore(entry, "Math Metrix");
    }
  }

  void _generateNewQuestion() {
    if (controller.currentQuestion.value > 10) {
      if (!overlays.isActive('GameOver')) {
        overlays.add('GameOver');
        gameOver();
      }
      return;
    }

    final questionData =
        QuestionGenerator.generate(gamecontroller.selectedLevel.value);
    questionComponent = QuestionComponent(questionData.question);
    answerComponents = [];

    for (int i = 0; i < questionData.answers.length; i++) {
      answerComponents.add(AnswerComponent(
        text: _formatAnswerText(
            questionData.answers[i], questionData.correctAnswer),
        isCorrect: questionData.answers[i] == questionData.correctAnswer,
        index: i,
        onPressed: (isCorrect) {
          if (isCorrect) {
            AudioService.acc();
            controller.correctAnswers.value++;
            controller.currentQuestion.value++;
            resetQuestion();
          } else {
            AudioService.wrong();
            controller.currentQuestion.value++;
            resetQuestion();
          }
        },
      ));
    }

    add(questionComponent);
    for (var answer in answerComponents) {
      add(answer);
    }
  }

  String _formatAnswerText(double answer, double correctAnswer) {
    bool isDesimal = correctAnswer % 1 != 0;
    if (isDesimal) {
      return answer.toStringAsFixed(2);
    } else {
      return answer.toInt().toString();
    }
  }

  Future<void> resetQuestion() async {
    removeAll([...answerComponents, questionComponent]);
    answerComponents.clear();
    questionComponent.removeFromParent();
    await Future.delayed(Duration(milliseconds: 100));
    _generateNewQuestion();
  }

  Future<void> exitGame() async {
    removeAll([...answerComponents, questionComponent]);
    answerComponents.clear();
    questionComponent.removeFromParent();
    controller.lastElapsedTime = "00:00";
    controller.elapsedTimeString.value = "00:00";
    controller.currentQuestion.value = 1;
    controller.correctAnswers.value = 0;
    stopTimer();
    await Future.delayed(Duration(milliseconds: 100));
    overlays.remove('ExitButton');
  }

  void restartGame() {
    stopTimer();
    controller.elapsedTimeString.value = "00:00";
    controller.startTime = DateTime.now();
    answerComponents.clear();
    questionComponent.removeFromParent();
    controller.currentQuestion.value = 1;
    controller.correctAnswers.value = 0;
    startGame();
    overlays.remove('GameOver');
  }
}
