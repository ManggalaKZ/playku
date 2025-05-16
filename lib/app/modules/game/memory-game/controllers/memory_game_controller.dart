import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/services/queue_service.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/dialog_new_leaderboard.dart';
import 'package:playku/core/core.dart';
import 'package:playku/core/core_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryCard {
  final int value;
  bool isFlipped;
  bool isMatched;

  MemoryCard(
      {required this.value, this.isFlipped = false, this.isMatched = false});
}

class MemoryGameController extends GetxController {
  var selectedLevel = GameLevel.easy.obs;
  String level = "eazy";
  int lengCard = 8;
  MemoryGame? game;
  var isCountdownFinished = false.obs;
  var isRestartingGame = false.obs;
  var leaderboard = <Leaderboard>[].obs;
  var elapsedTimeString = "0:00".obs;
  late DateTime startTime;
  var userModel = Rxn<UserModel>();
  var cards = <MemoryCard>[].obs;
  var firstSelectedIndex = (-1).obs;
  var isProcessing = false.obs;

  var isPaused = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    setLevel();
    loadUserFromPrefs();
  }

  void setLevel() {
    switch (selectedLevel.value) {
      case GameLevel.easy:
        level = "eazy";
        lengCard = 16;
        generateCards();
        break;
      case GameLevel.medium:
        level = "medium";
        lengCard = 20;
        generateCards();
        break;
      case GameLevel.hard:
        level = "hard";
        lengCard = 24;
        generateCards();
        break;
    }
  }

  void generateCards() {
    if (lengCard % 2 != 0) {
      throw Exception("Jumlah kartu harus genap!");
    }

    List<int> values = List.generate(
        lengCard ~/ 2, (index) => index + 1); // Setengah dari jumlah total
    List<int> shuffledValues = List.from(values)..addAll(values);
    shuffledValues.shuffle();

    cards.clear();
    cards.assignAll(
        shuffledValues.map((val) => MemoryCard(value: val)).toList());
  }

  int convertTimeToSeconds(String lastElapsedTime) {
    List<String> parts = lastElapsedTime.split(":");
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    return (minutes * 60) + seconds;
  }

  void setGame(MemoryGame gameInstance) {
    game = gameInstance;
  }

  void startGame() {
    startTime = DateTime.now();
    debugPrint("Countdown selesai! Game dimulai...");
    isCountdownFinished.value = true;
    isRestartingGame.value = false;
    restartGame();
  }

  void mainlagi() {
    isCountdownFinished.value = false;
    isProcessing.value = false;
    elapsedTimeString.value = "0:00";
    generateCards();
  }

  void restartGame() {
    firstSelectedIndex.value = -1;
    isProcessing.value = false;
    elapsedTimeString.value = "0:00";
    _startTimer();
  }

  void _startTimer() {
    debugPrint("Timer dimulai"); // Tambahkan ini untuk debug
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused.value) {
        Duration elapsed = DateTime.now().difference(startTime);
        int minutes = elapsed.inMinutes;
        int seconds = elapsed.inSeconds % 60;
        elapsedTimeString.value =
            "$minutes:${seconds.toString().padLeft(2, '0')}";
        debugPrint(
            "waktu${elapsedTimeString.value}"); // Tambahkan ini untuk debug
      }
    });
  }

  void pauseGame() {
    isPaused.value = true;
    _timer?.cancel();
  }

  void resumeGame() {
    isPaused.value = false;
    startTime = DateTime.now().subtract(Duration(
      minutes: int.parse(elapsedTimeString.value.split(":")[0]),
      seconds: int.parse(elapsedTimeString.value.split(":")[1]),
    ));
    _startTimer();
  }

  void exitGame() async {
    final homeController = Get.find<HomeController>();
    homeController.userController.loadUserFromPrefs();
    // Navigasi ke Home
    Get.offAllNamed(Routes.HOME);
    await Future.delayed(Duration(milliseconds: 1400));
    isCountdownFinished.value = false;
    elapsedTimeString.value = "0:00";
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void onCardTapped(int index) async {
    if (isProcessing.value || cards[index].isFlipped || cards[index].isMatched)
      return;

    cards[index].isFlipped = true;
    cards.refresh();

    if (firstSelectedIndex.value == -1) {
      firstSelectedIndex.value = index;
    } else {
      isProcessing.value = true;

      await Future.delayed(const Duration(milliseconds: 800));

      if (cards[firstSelectedIndex.value].value == cards[index].value) {
        AudioService.acc();
        cards[firstSelectedIndex.value].isMatched = true;
        cards[index].isMatched = true;
      } else {
        AudioService.wrong();
        cards[firstSelectedIndex.value].isFlipped = false;
        cards[index].isFlipped = false;
      }

      firstSelectedIndex.value = -1;
      isProcessing.value = false;
      cards.refresh();
    }

    if (_isGameCompleted()) {
      stopTimer();
      completedGame();
      Future.delayed(const Duration(milliseconds: 500), game?.gameOver);
    }
  }

  Future<void> loadUserFromPrefs() async {
    var userData = await SharedPreferenceHelper.getUserData();

    if (userData != null) {
      userModel.value = UserModel(
        point: userData["point"],
        username: userData["name"],
        id: userData["id"],
        name: userData["username"],
        email: userData["email"],
      );
      debugPrint("User berhasil dimuat: ${userModel.value!.id}");
    }
  }

  void completedGame() async {
    GameController controller = Get.put(GameController());
    int finalTime = convertTimeToSeconds(elapsedTimeString.value);

    int finalScore = 10;
    String userId = userModel.value!.id ?? "";
    String now = DateTime.now().toString();
    String levels = selectedLevel.value.toString().split('.').last;

    Map<String, dynamic> gameResult = {
      'userId': userId,
      'gameId': controller.idgame,
      'score': finalScore,
      'timePlay': finalTime,
      'level': levels,
      'playedAt': now,
    };

    bool success = await GameService.postGameResult(
      userId: userId,
      gameId: controller.idgame,
      score: finalScore,
      timePlay: finalTime,
      level: levels,
      playedAt: now,
    );

    if (!success) {
      await QueueService.addToQueue(gameResult);
    } else {
      await QueueService.removeFromQueue(gameResult);
      debugPrint("Data gameplay berhasil dikirim!");
      int? newPoint = await PointService.updateUserPoint(userId, 5);
      if (newPoint != null) {
        userModel.value = userModel.value!.copyWith(point: newPoint);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', jsonEncode(userModel.value!.toJson()));
        debugPrint(
            "Point berhasil disinkronkan ke SharedPreferences: $newPoint");
        HomeController homeController = Get.find<HomeController>();
        homeController.userController.loadUserFromPrefs();
        homeController.userController.userModel.refresh();
        homeController.leaderboardController.loadLeaderboard();
      }
    }
    await QueueService.processQueue();

    // .then((success) async {
    //   if (success) {
    //     debugPrint("Data gameplay berhasil dikirim!");
    //     int? newPoint = await PointService.updateUserPoint(userId, 5);
    //     if (newPoint != null) {
    //       userModel.value = userModel.value!.copyWith(point: newPoint);
    //       SharedPreferences prefs = await SharedPreferences.getInstance();
    //       prefs.setString('user', jsonEncode(userModel.value!.toJson()));
    //       debugPrint("Point berhasil disinkronkan ke SharedPreferences: $newPoint");
    //       HomeController homeController = Get.find<HomeController>();
    //       homeController.userController.loadUserFromPrefs();
    //       homeController.userController.userModel.refresh();
    //       homeController.leaderboardController.loadLeaderboard();
    //     }
    //   } else {
    //     debugPrint("Gagal mengirim data gameplay.");
    //   }
    // });

    Leaderboard entry = Leaderboard(
      userId: userId,
      gameId: controller.idgame,
      score: finalScore,
      timePlay: finalTime,
      played_at: now,
      level: levels,
    );

    addScore(entry, "Memory Game");
  }

  bool _isGameCompleted() {
    return cards.every((card) => card.isMatched);
  }

  Future<void> loadLeaderboard(int gameId) async {
    String levels = selectedLevel.value.toString().split('.').last;

    try {
      leaderboard.value =
          await LeaderboardService.getLeaderboard(gameId, levels);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> addScore(Leaderboard entry, String gameName) async {
    List<Leaderboard> before =
        await LeaderboardService.getLeaderboard(entry.gameId, entry.level);
    await LeaderboardService.updateLeaderboard(entry);
    List<Leaderboard> after =
        await LeaderboardService.getLeaderboard(entry.gameId, entry.level);

    bool isChanged = false;
    bool wasInBefore = before
        .any((b) => b.userId == entry.userId && b.timePlay == entry.timePlay);
    bool isInAfter = after
        .any((a) => a.userId == entry.userId && a.timePlay == entry.timePlay);

    if (!wasInBefore && isInAfter) {
      isChanged = true;
    }
    for (var beforeEntry in before) {
      bool stillExists = after.any((a) =>
          a.userId == beforeEntry.userId &&
          a.timePlay == beforeEntry.timePlay &&
          a.played_at == beforeEntry.played_at);
      if (!stillExists) {
        isChanged = true;
        break;
      }
    }
    if (isChanged) {
      int? newIndex = after.indexWhere(
          (a) => a.userId == entry.userId && a.timePlay == entry.timePlay);
      DialogNewLeaderboard.showLeaderboardCongrats(
        gameName,
        beforeRanks: before,
        afterRanks: after,
        newRankIndex: newIndex >= 0 ? newIndex : null,
      );
    }
  }
}
