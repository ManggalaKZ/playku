import 'dart:convert';

import 'package:http/http.dart' as http;

class GameService {
  static const String baseUrl =
      'https://lvqfhlohgdaqudfuivqb.supabase.co/rest/v1/';
  static const Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Content-Type': 'application/json',
  };

  static Future<String> getGameName(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}games?id=eq.$gameId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0]['name'];
        }
      }
      print("code get name ${response.statusCode}");
      return "Unknown Game";
    } catch (e) {
      return "Unknown Game";
    }
  }

  static Future<bool> postGameResult({
    required String userId,
    required int gameId,
    required int score,
    required int timePlay,
    required String playedAt,
    required String level,
  }) async {
    final Map<String, dynamic> data = {
      "user_id": userId,
      "game_id": gameId,
      "score": score,
      "time_play": timePlay,
      "level": level,
      "played_at": playedAt,
    };

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}gameplay"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        print("Data berhasil dikirim: ${response.body}");
        return true;
      } else {
        print("Gagal mengirim data: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saat mengirim data: $e");
      return false;
    }
  }
}
