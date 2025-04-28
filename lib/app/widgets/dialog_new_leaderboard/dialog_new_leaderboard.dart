import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/widgets/dialog_new_leaderboard/animated_leaderboard_dialog.dart';

class DialogNewLeaderboard {
  static void showLeaderboardCongrats(
    String gameName, {
    List<Leaderboard>? beforeRanks,
    List<Leaderboard>? afterRanks,
    int? newRankIndex,
  }) {
    Get.dialog(
      AnimatedLeaderboardDialog(
        gameName: gameName,
        beforeRanks: beforeRanks ?? [],
        afterRanks: afterRanks ?? [],
        newRankIndex: newRankIndex,
      ),
      barrierDismissible: false,
    );
  }
}