import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/modules/game/answer-question/controller/answer_question_controller.dart';
import 'package:playku/app/modules/game/controller/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playku/app/data/services/game_service.dart';

class QueueService {
  static const String _queueKey = 'game_result_queue';

  static Future<void> addToQueue(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    queue.add(jsonEncode(data));
    await prefs.setStringList(_queueKey, queue);
    debugPrint('Data ditambahkan ke queue: $data');
  }

  static Future<void> removeFromQueue(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    queue.removeWhere((item) => item == jsonEncode(data));
    await prefs.setStringList(_queueKey, queue);
    debugPrint('Data dihapus dari queue: $data');
  }

  static Future<void> processQueue() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;

    List<String> newQueue = [];
    for (String item in queue) {
      Map<String, dynamic> data = jsonDecode(item);
      bool success = await GameService.postGameResult(
        userId: data['userId'],
        gameId: data['gameId'],
        score: data['score'],
        timePlay: data['timePlay'],
        level: data['level'],
        playedAt: data['playedAt'],
      );

      if (success) {
        await removeFromQueue(data);

        final entry = Leaderboard(
          userId: data['userId'],
          gameId: data['gameId'],
          score: data['score'],
          timePlay: data['timePlay'],
          level: data['level'],
          played_at: data['playedAt'],
        );
        String gameName =
            await GameService.getGameName(data['gameId'].toString());

        final gamecontroller = Get.put(AnswerQuestionController());
        gamecontroller.addScore(entry, gameName);
      }

      if (!success) {
        newQueue.add(item);
      } else {
        debugPrint('Data berhasil dikirim ulang ke Supabase: $data');
      }
    }
    await prefs.setStringList(_queueKey, newQueue);
  }
}
