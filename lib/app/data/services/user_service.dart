import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl =
      'https://lvqfhlohgdaqudfuivqb.supabase.co/rest/v1/';
  static const Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
    'Content-Type': 'application/json',
  };
  
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
          .maybeSingle();

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
