import 'dart:async';
import 'package:get/get.dart';

import 'package:playku/app/widgets/dialog_new_leaderboard/dialog_new_leaderboard.dart';
import 'package:playku/core.dart';

class AnswerQuestionController extends GetxController {
  var userModel = Rxn<UserModel>();
  var currentQuestion = 1.obs;
  var correctAnswers = 0.obs;
  var elapsedTimeString = "0:00".obs;
  var isRestartingGame = false.obs;
  var isCountdownFinished = false.obs;
  bool isPaused = false;

  Timer? _timer;
  var leaderboard = <Leaderboard>[].obs;
  String lastElapsedTime = "";

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
    }
  }

  void startTimer() {
    print("Timer dimulai"); // Tambahkan ini untuk debug
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        Duration elapsed = DateTime.now().difference(startTime);
        int minutes = elapsed.inMinutes;
        int seconds = elapsed.inSeconds % 60;
        elapsedTimeString.value =
            "$minutes:${seconds.toString().padLeft(2, '0')}";
        print(elapsedTimeString.value); // Tambahkan ini untuk debug
      }
    });
  }

  late DateTime startTime;

  void startGame() {
    startTime = DateTime.now();
    startTimer();
    currentQuestion.value = 1;
    correctAnswers.value = 0;
  }

  void pauseGame() {
    isPaused = true;
    _timer?.cancel();
  }

  void resumeGame() {
    isPaused = false;
    startTime = DateTime.now().subtract(Duration(
      minutes: int.parse(elapsedTimeString.value.split(":")[0]),
      seconds: int.parse(elapsedTimeString.value.split(":")[1]),
    ));
    startTimer();
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

  Future<void> loadLeaderboard(int gameId, String levels) async {
    try {
      leaderboard.value =
          await LeaderboardService.getLeaderboard(gameId, levels);
    } catch (e) {
      print("Error: $e");
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
