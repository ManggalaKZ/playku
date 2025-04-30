import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/core.dart';

class LeaderboardController extends GetxController {
  var leaderboard = <Leaderboard>[].obs;
  var isLoadingui = false.obs;
  var userTopLeaderboard = Rxn<Leaderboard>();
  var userLeaderboardRank = 0.obs;
  var selectedGameId = (-1).obs;
  var selectedLevel = "Semua".obs;
  var filteredLeaderboard = <Leaderboard>[].obs;
  Map<String, Map<String, List<Leaderboard>>> groupedLeaderboard = {};
  var isLoading = false.obs;

  UserController userController = Get.find<UserController>();

  Future<void> loadLeaderboard() async {
    try {
      isLoadingui.value = true;
      leaderboard.value = await LeaderboardService.getLeaderboardAll();
      filterUserTopLeaderboard();
    } catch (e) {
    } finally {
      isLoadingui.value = false;
    }
  }

  void filterUserTopLeaderboard() {
    final userController = Get.find<UserController>();

    if (userController.userModel.value == null) {
      return;
    }

    final userId = userController.userModel.value!.id;

    Leaderboard? bestLeaderboard;
    int bestRank = -1;

    final gameLevelGroups =
        leaderboard.map((e) => {'gameId': e.gameId, 'level': e.level}).toSet();

    for (var group in gameLevelGroups) {
      final gameId = group['gameId']!;
      final level = group['level']!;

      final filtered = leaderboard
          .where((e) => e.gameId == gameId && e.level == level)
          .toList();

      filtered.sort((a, b) {
        if (b.score != a.score) {
          return b.score.compareTo(a.score);
        } else {
          return a.timePlay.compareTo(b.timePlay);
        }
      });

      int userIndex = filtered.indexWhere((e) => e.userId == userId);
      if (userIndex != -1 && userIndex < 3) {
        int currentRank = userIndex + 1;

        if (bestRank == -1 || currentRank < bestRank) {
          bestRank = currentRank;
          bestLeaderboard = filtered[userIndex];
        }
      }
    }

    if (bestLeaderboard != null) {
      userTopLeaderboard.value = bestLeaderboard;
      userLeaderboardRank.value = bestRank;
    } else {
      userTopLeaderboard.value = null;
      userLeaderboardRank.value = -1;
    }
  }

  void groupLeaderboardByGameAndLevel() {
    groupedLeaderboard.clear();

    for (var entry in filteredLeaderboard) {
      final gameName = entry.gameId == 0
          ? 'Math Metrix'
          : entry.gameId == 1
              ? 'Memory Game'
              : 'Minesweeper';
      final level = entry.level;

      groupedLeaderboard.putIfAbsent(gameName, () => {});
      groupedLeaderboard[gameName]!.putIfAbsent(level, () => []);
      groupedLeaderboard[gameName]![level]!.add(entry);
    }

    groupedLeaderboard.forEach((game, levels) {
      levels.forEach((level, list) {
        list.sort((a, b) => a.timePlay.compareTo(b.timePlay));
      });
    });
  }

  void filterLeaderboard() {
    final all = leaderboard;
    List<Leaderboard> filtered = [];

    if (selectedGameId.value == -1 && selectedLevel.value == "Semua") {
      filtered = all;
    } else if (selectedGameId.value == -1) {
      filtered = all.where((e) => e.level == selectedLevel.value).toList();
    } else {
      filtered = all.where((e) => e.gameId == selectedGameId.value).toList();
    }

    filteredLeaderboard.assignAll(filtered);
    groupLeaderboardByGameAndLevel();
  }

  String cekLeaderboard() {
    if ((userLeaderboardRank.value) == -1) {
      return "Main dulu";
    } else {
      return "#${userLeaderboardRank.value}";
    }
  }

  void showLeaderboard() {

    filterLeaderboard();
    groupLeaderboardByGameAndLevel();

    Get.dialog(
      LeaderboardDialog(controller: this),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
    );
  }

  void ontap() {
    AudioService.playButtonSound();
    loadLeaderboard();
    showLeaderboard();
  }

  Widget buildRankBadge(int index) {
    switch (index) {
      case 0:
        return const Text("🥇", style: TextStyle(fontSize: 20));
      case 1:
        return const Text("🥈", style: TextStyle(fontSize: 20));
      case 2:
        return const Text("🥉", style: TextStyle(fontSize: 20));
      default:
        return Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            shape: BoxShape.circle,
          ),
          child: Text(
            "${index + 1}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget buildGameFilterButton(int gameId, String label, int selectedId) {
    final isSelected = selectedId == gameId;

    return GestureDetector(
      onTap: () {
        selectedGameId.value = gameId;
        filterLeaderboard();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
