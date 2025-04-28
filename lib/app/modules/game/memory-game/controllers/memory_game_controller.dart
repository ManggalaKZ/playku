import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/dialog_new_leaderboard.dart';
import 'package:playku/core.dart';
import 'package:playku/core_game.dart';
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

  var userModel = Rxn<UserModel>();
  var cards = <MemoryCard>[].obs;
  var firstSelectedIndex = (-1).obs;
  var isProcessing = false.obs;

  var elapsedTime = 0.obs;
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
    List<int> shuffledValues = List.from(values)
      ..addAll(values); // Duplikat pasangan kartu
    shuffledValues.shuffle();

    cards.clear();
    cards.assignAll(
        shuffledValues.map((val) => MemoryCard(value: val)).toList());
  }

  void setGame(MemoryGame gameInstance) {
    game = gameInstance;
  }

  void startGame() {
    print("Countdown selesai! Game dimulai...");
    isCountdownFinished.value = true;
    isRestartingGame.value = false;
    restartGame();
  }

  void mainlagi() {
    isCountdownFinished.value = false;
    isProcessing.value = false;

    elapsedTime.value = 0;
    generateCards();
  }

  void restartGame() {
    firstSelectedIndex.value = -1;
    isProcessing.value = false;

    elapsedTime.value = 0;
    _startTimer();
  }

  void _startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime.value++;
    });
  }

  void pauseGame() {
    isPaused.value = true;
    stopTimer();
  }

  void resumeGame() {
    isPaused.value = false;
    _startTimer();
  }

  void exitGame() async {
    final homeController = Get.find<HomeController>();
    homeController.loadUserFromPrefs();
    // Navigasi ke Home
    Get.offAllNamed(Routes.HOME);
    await Future.delayed(Duration(milliseconds: 1400));
    isCountdownFinished.value = false;
    elapsedTime.value = 0;
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
      print("User berhasil dimuat: ${userModel.value!.id}");
    }
  }

  void completedGame() async {
    GameController controller = Get.put(GameController());
    int finalTime = elapsedTime.value;
    int finalScore = 10;
    String userId = userModel.value!.id ?? "";
    String now = DateTime.now().toString();
    String levels = selectedLevel.value.toString().split('.').last;

    loadLeaderboard(controller.idgame);

    print("User ID: $userId");
    print("Game ID: ${controller.idgame}");
    print("Final Score: $finalScore");
    print("Final Time: $finalTime");
    print("Date Now: $now");

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
        int? newPoint = await PointService.updateUserPoint(userId,5);
        if (newPoint != null) {
          userModel.value = userModel.value!.copyWith(point: newPoint);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', jsonEncode(userModel.value!.toJson()));
          print("Point berhasil disinkronkan ke SharedPreferences: $newPoint");
          HomeController homeController = Get.find<HomeController>();
          homeController.loadUserFromPrefs();
          homeController.userModel.refresh();
          homeController.loadLeaderboard();
        }
      } else {
        print("Gagal mengirim data gameplay.");
      }
    });

    // Simpan ke leaderboard
    Leaderboard entry = Leaderboard(
      userId: userId,
      gameId: controller.idgame,
      score: finalScore,
      timePlay: finalTime,
      played_at: now,
      level: levels,
    );

    addScore(entry);
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
      print("Error: $e");
    }
  }

  Future<void> addScore(Leaderboard entry) async {
    // 1. Ambil leaderboard sebelum update
    List<Leaderboard> before =
        await LeaderboardService.getLeaderboard(entry.gameId, entry.level);

    // 2. Update leaderboard
    await LeaderboardService.updateLeaderboard(entry);

    // 3. Ambil leaderboard setelah update
    List<Leaderboard> after =
        await LeaderboardService.getLeaderboard(entry.gameId, entry.level);

    bool isChanged = false;
    String message = "";

    // Cek jika ada user baru yang masuk leaderboard atau memperbaiki waktunya
    for (var afterEntry in after) {
      var beforeEntry = before.firstWhereOrNull((b) =>
          b.userId == afterEntry.userId && b.timePlay == afterEntry.timePlay);
      if (beforeEntry == null) {
        isChanged = true;
        int rank = after.indexWhere((a) =>
                a.userId == afterEntry.userId &&
                a.timePlay == afterEntry.timePlay) +
            1;
        message +=
            "User ${afterEntry.userId} mendapat leaderboard baru (Rank: $rank, Time: ${afterEntry.timePlay} detik)\n";
      }
    }

    // Cek jika ada skor user yang keluar leaderboard (termasuk jika digeser oleh skor barunya sendiri)
    for (var beforeEntry in before) {
      var afterEntry = after.firstWhereOrNull((a) =>
          a.userId == beforeEntry.userId && a.timePlay == beforeEntry.timePlay);
      if (afterEntry == null) {
        isChanged = true;
        message +=
            "Skor ${beforeEntry.timePlay} detik milik user ${beforeEntry.userId} keluar dari leaderboard\n";
      }
    }

    if (isChanged) {
      // Cari index user pada leaderboard terbaru
      int? newIndex = after.indexWhere((a) =>
        a.userId == entry.userId && a.timePlay == entry.timePlay);
      DialogNewLeaderboard.showLeaderboardCongrats(
        "Minesweeper",
        beforeRanks: before,
        afterRanks: after,
        newRankIndex: newIndex >= 0 ? newIndex : null,
      );
    }
  }

  void showGameOverDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Game Selesai! 🎉"),
        content: Text("Waktu bermain: ${elapsedTime.value} detik"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              restartGame();
            },
            child: const Text("Main Lagi"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
