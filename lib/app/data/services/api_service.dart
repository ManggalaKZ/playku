import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:playku/app/data/models/user_model.dart';

class AuthService extends GetxService {
  static const String baseUrl =
      'https://lvqfhlohgdaqudfuivqb.supabase.co/rest/v1/';
  static const Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Content-Type': 'application/json',
  };

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?username=eq.$username'),
        headers: headers,
      );

      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);

        if (usersJson.isNotEmpty) {
          UserModel user = UserModel.fromJson(usersJson.first);

          if (user.password == password) {
            return user;
          } else {
            print("Password salah");
            return null;
          }
        } else {
          print("Username tidak ditemukan");
          return null;
        }
      } else {
        print("Login gagal dengan status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final existing = await supabase
          .from('users')
          .select()
          .or('email.eq.$email,username.eq.$username')
          .maybeSingle();

      if (existing != null) {
        throw Exception('Email atau Username sudah digunakan.');
      }

      final response = await supabase
          .from('users')
          .insert({
            'username': username,
            'name': name,
            'email': email,
            'password': password,
            'point': 0,
            'avatar':
                null,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception("Gagal mendaftar: $e");
    }
  }

  static Future<int?> updateUserPoint(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('users').select('*').eq('id', userId).single();

      int currentPoint = response['point'] ?? 0;
      int newPoint = currentPoint + 5;

      await supabase.from('users').update({'point': newPoint}).eq('id', userId);
      await SharedPreferenceHelper.saveUserData(
        userId: response['id'],
        userName: response['username'],
        name: response['name'],
        userEmail: response['email'],
        avatar: response['avatar'] ?? "",
        point: newPoint,
      );

      print("User point updated in Supabase: $newPoint");
      return newPoint;
    } catch (e) {
      print("Error updating user point: $e");
      return null;
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

  static Future<List<Leaderboard>> getLeaderboard(
      int gameId, String level) async {
    try {
      print("Fetching leaderboard for game ID: $gameId and level: $level...");

      final response = await http.get(
        Uri.parse("${baseUrl}leaderboard?game_id=eq.$gameId&level=eq.$level"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("Leaderboard data received: ${data.length} entries");

        List<Leaderboard> leaderboard = data
            .map((entry) => Leaderboard.fromJson(entry))
            .toList()
          ..sort((a, b) =>
              a.timePlay.compareTo(b.timePlay)); // sort waktu tercepat

        print(
            "Filtered leaderboard (game_id=$gameId, level=$level): ${leaderboard.length} entries");

        return leaderboard.take(3).toList(); // Ambil 3 tercepat
      } else {
        print(
            "Failed to fetch leaderboard. Status code: ${response.statusCode}");
        throw Exception("Gagal mengambil leaderboard");
      }
    } catch (e) {
      print("Error in getLeaderboard: $e");
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
        print("status codes ${response.statusCode}");
        print("Leaderboard data received: ${data.length} entries");

        List<Leaderboard> leaderboard =
            await Future.wait(data.map((entry) async {
          Map<String, String> userDetails =
              await getUserDetails(entry['user_id'].toString());
          String gameName = await getGameName(entry['game_id'].toString());

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
      print("Error in getLeaderboardAll: $e");
      return [];
    }
  }

  static Future<Map<String, String>> getUserDetails(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}users?id=eq.$userId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          var userData = data[0];
          return {
            'username': userData['username'] ?? "Unknown User",
            'avatar': userData['avatar'] ?? "",
          };
        }
      }
      return {'username': "Unknown User", 'avatar': ""};
    } catch (e) {
      return {'username': "Unknown User", 'avatar': ""};
    }
  }

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

  static Future<void> updateLeaderboard(Leaderboard newEntry) async {
    try {
      print(
          "Updating leaderboard for game ID: ${newEntry.gameId} at level: ${newEntry.level}...");

      List<Leaderboard> currentLeaderboard =
          await getLeaderboard(newEntry.gameId, newEntry.level);
      print("Current leaderboard entries: ${currentLeaderboard.length}");

      if (currentLeaderboard.length < 3 ||
          newEntry.timePlay < currentLeaderboard.last.timePlay) {
        if (currentLeaderboard.length == 3) {
          final worstId = currentLeaderboard.last.id;
          print("Deleting worst entry with ID: $worstId");

          final deleteResponse = await http.delete(
            Uri.parse("${baseUrl}leaderboard?id=eq.$worstId"),
            headers: headers,
          );

          if (deleteResponse.statusCode == 204) {
            print("Deleted worst entry successfully.");
          } else {
            print(
                "Failed to delete. Status code: ${deleteResponse.statusCode}");
          }
        }

        print("Adding new entry to leaderboard...");
        final postResponse = await http.post(
          Uri.parse("${baseUrl}leaderboard"),
          headers: headers,
          body: jsonEncode(newEntry.toJson()),
        );

        if (postResponse.statusCode == 201) {
          print("New entry added successfully!");
        } else {
          print(
              "Failed to add new entry. Status code: ${postResponse.statusCode}");
        }
      } else {
        print("New entry is not in the top 3, skipping update.");
      }
    } catch (e) {
      print("Error in updateLeaderboard: $e");
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    final supabase = Supabase.instance.client;

    print("[DEBUG] Memulai update user...");
    print("[DEBUG] ID user: $userId");
    print("[DEBUG] Data yang dikirim: $data");

    try {
      final response = await supabase
          .from('users')
          .update(data)
          .eq('id', userId)
          .select()
          .maybeSingle(); // <- tidak akan null jika update berhasil

      print("[DEBUG] Response dari Supabase: $response");

      if (response == null) {
        print("[ERROR] Response NULL, user tidak ditemukan atau update gagal");
        throw Exception("User not found or update failed");
      }

      print("[SUCCESS] Data user berhasil diupdate");
    } catch (e, stackTrace) {
      print("[ERROR] Gagal update user: $e");
      print("[STACKTRACE] $stackTrace");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUser(String userId) async {
    final supabase = Supabase.instance.client;

    final response =
        await supabase.from('users').select().eq('id', userId).maybeSingle();

    if (response == null) throw Exception("User not found");

    return response;
  }
}
