import 'dart:convert';
import 'package:playku/app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;


class AuthService {
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
            'avatar': null,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception("Gagal mendaftar: $e");
    }
  }
}
