import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playku/core.dart';

class LeaderboardService {
  static const String baseUrl =
      'https://lvqfhlohgdaqudfuivqb.supabase.co/rest/v1/';
  static const Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Content-Type': 'application/json',
  };

  static Future<List<Leaderboard>> getLeaderboard(
      int gameId, String level) async {
    try {
      debugPrint(
          "Fetching leaderboard for game ID: $gameId and level: $level...");

      final response = await http.get(
        Uri.parse("${baseUrl}leaderboard?game_id=eq.$gameId&level=eq.$level"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        debugPrint("Leaderboard data received: ${data.length} entries");

        List<Leaderboard> leaderboard = data
            .map((entry) => Leaderboard.fromJson(entry))
            .toList()
          ..sort((a, b) => a.timePlay.compareTo(b.timePlay));

        debugPrint(
            "Filtered leaderboard (game_id=$gameId, level=$level): ${leaderboard.length} entries");

        return leaderboard.take(3).toList();
      } else {
        debugPrint(
            "Failed to fetch leaderboard. Status code: ${response.statusCode}");
        throw Exception("Gagal mengambil leaderboard");
      }
    } catch (e) {
      debugPrint("Error in getLeaderboard: $e");
      return [];
    }
  }

  static Future<List<Leaderboard>> getLeaderboardAll() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}leaderboard"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        debugPrint("status codes ${response.statusCode}");
        debugPrint("Leaderboard data received: ${data.length} entries");

        List<Leaderboard> leaderboard =
            await Future.wait(data.map((entry) async {
          Map<String, String> userDetails =
              await UserService.getUserDetails(entry['user_id'].toString());
          String gameName =
              await GameService.getGameName(entry['game_id'].toString());

          return Leaderboard.fromJson(entry).copyWith(
            username: userDetails['username'],
            avatar: userDetails['avatar'],
            gameName: gameName,
          );
        }));

        leaderboard.sort((a, b) => a.timePlay.compareTo(b.timePlay));
        return leaderboard;
      } else {
        throw Exception("Gagal mengambil leaderboard");
      }
    } catch (e) {
      debugPrint("Error in getLeaderboardAll: $e");
      return [];
    }
  }

  static Future<void> updateLeaderboard(Leaderboard newEntry) async {
    try {
      debugPrint(
          "Updating leaderboard for game ID: ${newEntry.gameId} at level: ${newEntry.level}...");

      List<Leaderboard> currentLeaderboard =
          await getLeaderboard(newEntry.gameId, newEntry.level);
      debugPrint("Current leaderboard entries: ${currentLeaderboard.length}");

      if (currentLeaderboard.length < 3 ||
          newEntry.timePlay < currentLeaderboard.last.timePlay) {
        if (currentLeaderboard.length == 3) {
          final worstId = currentLeaderboard.last.id;
          debugPrint("Deleting worst entry with ID: $worstId");

          final deleteResponse = await http.delete(
            Uri.parse("${baseUrl}leaderboard?id=eq.$worstId"),
            headers: headers,
          );

          if (deleteResponse.statusCode == 204) {
            debugPrint("Deleted worst entry successfully.");
          } else {
            debugPrint(
                "Failed to delete. Status code: ${deleteResponse.statusCode}");
          }
        }

        debugPrint("Adding new entry to leaderboard...");
        final postResponse = await http.post(
          Uri.parse("${baseUrl}leaderboard"),
          headers: headers,
          body: jsonEncode(newEntry.toJson()),
        );

        if (postResponse.statusCode == 201) {
          debugPrint("New entry added successfully!");
        } else {
          debugPrint(
              "Failed to add new entry. Status code: ${postResponse.statusCode}");
        }
      } else {
        debugPrint("New entry is not in the top 3, skipping update.");
      }
    } catch (e) {
      debugPrint("Error in updateLeaderboard: $e");
    }
  }
}
