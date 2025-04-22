import 'dart:async';
import 'dart:convert';
import 'package:flame/events.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'package:playku/app/data/services/api_service.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/data/services/game_service.dart';
import 'package:playku/app/data/services/leaderboard_service.dart';
import 'package:playku/app/data/services/point_service.dart';
import 'package:playku/app/modules/game/answer-question/component/AnswerComponent.dart';
import 'package:playku/app/modules/game/controller/game_controller.dart';
import 'package:playku/app/modules/home/controller/home_controller.dart';
import 'package:playku/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/user_model.dart';
import '../utils/question_generator.dart';
import '../component/question_component.dart';
import 'package:flutter/material.dart';

class AnswerQuestionGame extends FlameGame with TapDetector {
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
    loadUserFromPrefs();
    _startTime = DateTime.now();
  }

  @override
  Color backgroundColor() => AppColors.primary;

  @override
  void onTapUp(TapUpInfo event) {
    super.onTapUp(event);
    Vector2 tapPosition = event.eventPosition.global;
    for (var answer in answerComponents) {
      if (answer.containsPoint(tapPosition)) {
        print("Tap di dalam AnswerComponent ${answer.text}");

        answer.onPressed(answer.isCorrect);
        break;
      }
    }
  }

  Future<void> loadUserFromPrefs() async {
    var userData = await SharedPreferenceHelper.getUserData();

    if (userData != null) {
      userModel.value = UserModel(
          username: userData["name"],
          id: userData["id"],
          name: userData["username"],
          email: userData["email"],
          avatar: userData["avatar"],
          point: userData["point"]);
      print("User berhasil dimuat: ${userModel.value!.id}");
    }
  }

  void startGame() {
    print("Permainan dimulai!");

    _startTime = DateTime.now(); // Reset waktu mulai ke waktu saat ini
    _startTimer(); // Jalankan timer baru

    _generateNewQuestion();
    overlays.remove('Countdown');
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        Duration elapsed = DateTime.now().difference(_startTime);
        int minutes = elapsed.inMinutes;
        int seconds = elapsed.inSeconds % 60;

        elapsedTimeString.value =
            "$minutes:${seconds.toString().padLeft(2, '0')}";
      }
    });
  }

  void pauseGame() {
    _isPaused = true;
    _timer?.cancel();
    // overlays.add('PauseMenu');
  }

  void resumeGame() {
    _isPaused = false;
    _startTime = DateTime.now().subtract(Duration(
      minutes: int.parse(elapsedTimeString.value.split(":")[0]),
      seconds: int.parse(elapsedTimeString.value.split(":")[1]),
    ));
    _startTimer();
    // overlays.remove('PauseMenu');
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  int convertTimeToSeconds(String lastElapsedTime) {
    List<String> parts = lastElapsedTime.split(":");
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    return (minutes * 60) + seconds;
  }

  void gameOver() async {
    stopTimer();
    GameController controller = Get.put(GameController());
    HomeController homeController = Get.find<HomeController>();

    lastElapsedTime = elapsedTimeString.value;
    int finalTime = convertTimeToSeconds(lastElapsedTime);
    int finalScore = correctAnswers;
    String userId = userModel.value!.id ?? "";
    String now = DateTime.now().toString();
    String levels =
        gamecontroller.selectedLevel.value.toString().split('.').last;
    loadLeaderboard(controller.idgame);

    GameService.postGameResult(
      userId: userId,
      gameId: controller.idgame,
      score: finalScore,
      timePlay: finalTime,
      level: levels,
      playedAt: now,
    ).then((success) async {
      if (success) {
        print("Data gameplay berhasil dikirim!");
        lastElapsedTime = "00:00";
        int? newPoint = await PointService.updateUserPoint(userId);
        if (newPoint != null) {
          userModel.value = userModel.value!.copyWith(point: newPoint);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', jsonEncode(userModel.value!.toJson()));

          HomeController homeController = Get.find<HomeController>();
          homeController.loadUserFromPrefs();
          homeController.userModel.refresh();
          homeController.loadLeaderboard();
        }
      } else {
        print("Gagal mengirim data gameplay.");
      }
    });

    Leaderboard entry = Leaderboard(
        userId: userId,
        gameId: controller.idgame,
        score: finalScore,
        timePlay: finalTime,
        played_at: now,
        level: levels);

    await Future.delayed(Duration(milliseconds: 1));
    if (finalScore == 10) {
      addScore(entry);
    }
  }

  Future<void> loadLeaderboard(int gameId) async {
    String levels =
        gamecontroller.selectedLevel.value.toString().split('.').last;

    try {
      leaderboard.value = await LeaderboardService.getLeaderboard(gameId, levels);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> addScore(Leaderboard entry) async {
    await LeaderboardService.updateLeaderboard(entry);
    await loadLeaderboard(entry.gameId);
  }

  void _generateNewQuestion() {
    if (currentQuestion > 10) {
      print('Game Over dipanggil, soal ke: $currentQuestion');
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

    print("Soal: ${questionData.question}");
    print("Jawaban Benar: ${questionData.correctAnswer}");
    print("Opsi Jawaban: ${questionData.answers}");
    for (int i = 0; i < questionData.answers.length; i++) {
      answerComponents.add(AnswerComponent(
        text: _formatAnswerText(
            questionData.answers[i], questionData.correctAnswer),
        isCorrect: questionData.answers[i] == questionData.correctAnswer,
        index: i,
        onPressed: (isCorrect) {
          print("index $i");
          print("jawaban yang benar: ${questionData.correctAnswer}");

          if (isCorrect) {
            AudioService.acc();
            correctAnswers++;
            currentQuestion++;
            print("Komponen sebelum reset: ${questionData.answers.length}");
            resetQuestion();
            print("Komponen setelah reset: ${questionData.answers.length}");
          } else {
            AudioService.wrong();
            print("jawaban salah");
            currentQuestion++;
            print("Komponen sebelum reset: ${questionData.answers.length}");
            resetQuestion();
            print("Komponen setelah reset: ${questionData.answers.length}");
          }

          print("berhasil di reset");
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

    print("Game telah di-reset sepenuhnya");
  }

  Future<void> exitGame() async {
    print("Mulai keluar dari game...");

    removeAll([...answerComponents, questionComponent]);
    answerComponents.clear();
    questionComponent.removeFromParent();
    lastElapsedTime = "00:00";
    elapsedTimeString.value = "00:00";
    currentQuestion = 1;
    correctAnswers = 0;
    stopTimer();
    await Future.delayed(Duration(milliseconds: 100));
    overlays.remove('ExitButton');

    print("Game berhasil di-reset & keluar.");
  }

  void restartGame() {
    print("Restarting game...");

    stopTimer();
    elapsedTimeString.value = "00:00";

    _startTime = DateTime.now();

    answerComponents.clear();
    questionComponent.removeFromParent();
    print("All components removed.");

    currentQuestion = 1;
    correctAnswers = 0;
    print("Question & Score reset.");

    startGame(); // Mulai game baru, termasuk timer

    overlays.remove('GameOver');
    print("GameOver overlay removed.");
  }
}
