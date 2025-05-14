import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'package:playku/app/data/models/user_model.dart';
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
  final supabase = Supabase.instance.client;

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

  Future<UserModel?> purchaseBorder(
      String userId, String borderId, int borderPrice) async {
    try {
      debugPrint("🔍 Mengambil data user dari Supabase...");
      final userResponse = await supabase
          .from('users')
          .select('point, ownedBorderIds')
          .eq('id', userId)
          .single();

      debugPrint("✅ Data user: $userResponse");

      int currentPoint = userResponse['point'] ?? 0;

      debugPrint("💰 Poin sekarang: $currentPoint");

      List<String> currentOwnedBorders = [];
      final dynamic ownedBordersData = userResponse['ownedBorderIds'];

      if (ownedBordersData != null) {
        if (ownedBordersData is List) {
          currentOwnedBorders = List<String>.from(
            ownedBordersData
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty),
          );
        } else if (ownedBordersData is String) {
          try {
            List<dynamic> decodedList = jsonDecode(ownedBordersData);
            currentOwnedBorders = List<String>.from(decodedList
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty));
          } catch (e) {
            debugPrint(
                "⚠️ Error decoding ownedBorderIds string: $e. Data: $ownedBordersData");
          }
        }
      }

      debugPrint("🧾 Border dimiliki: $currentOwnedBorders");

      if (currentPoint < borderPrice) {
        throw Exception("Poin tidak cukup untuk membeli border ini.");
      }

      if (currentOwnedBorders.contains(borderId)) {
        throw Exception("Anda sudah memiliki border ini.");
      }

      int newPoint = currentPoint - borderPrice;
      List<String> newOwnedBorders = List.from(currentOwnedBorders)
        ..add(borderId);

      debugPrint(
          "🛒 Update ke Supabase dengan poin baru: $newPoint dan border baru: $newOwnedBorders");

      final updateResponse = await supabase
          .from('users')
          .update({
            'point': newPoint,
            'ownedBorderIds': newOwnedBorders,
          })
          .eq('id', userId)
          .select()
          .single();

      debugPrint("📦 Update response: $updateResponse");
      debugPrint("📦 Update response: $updateResponse");

      final updatedUserData = UserModel.fromJson(updateResponse);

      debugPrint("✅ UserModel setelah update: ${updatedUserData.toJson()}");

      await SharedPreferenceHelper.saveUserData(
        userId: updatedUserData.id,
        userName: updatedUserData.username,
        name: updatedUserData.name,
        userEmail: updatedUserData.email,
        avatar: updatedUserData.avatar ?? "",
        point: updatedUserData.point,
        ownedBorderIds: updatedUserData.ownedBorderIds,
        usedBorderIds: updatedUserData.usedBorderIds,
      );

      debugPrint(
          "🎉 Pembelian border berhasil. User diperbarui di SharedPreferences.");
      return updatedUserData;
    } catch (e) {
      debugPrint("🔥 Error purchasing border: $e");
      if (e is PostgrestException) {
        debugPrint("🧨 Supabase error: ${e.message}");
      }
      throw Exception(e.toString());
    }
  }

  Future<void> updateUsedBorder(String userId, String borderId) async {
    debugPrint("[DEBUG] Memulai update used border...");
    debugPrint("[DEBUG] User ID: $userId, Border ID: $borderId");

    try {
      await supabase
          .from('users')
          .update({'usedBorderIds': borderId}).eq('id', userId);

      debugPrint("[SUCCESS] Used border berhasil diupdate untuk user $userId");
    } catch (e, stackTrace) {
      debugPrint("[ERROR] Gagal update used border: $e");
      debugPrint("[STACKTRACE] $stackTrace");
      throw Exception("Gagal memperbarui border yang digunakan: $e");
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    final supabase = Supabase.instance.client;

    debugPrint("[DEBUG] Memulai update user...");
    debugPrint("[DEBUG] ID user: $userId");
    debugPrint("[DEBUG] Data yang dikirim: $data");

    try {
      final response = await supabase
          .from('users')
          .update(data)
          .eq('id', userId)
          .select()
          .maybeSingle();

      debugPrint("[DEBUG] Response dari Supabase: $response");

      if (response == null) {
        debugPrint(
            "[ERROR] Response NULL, user tidak ditemukan atau update gagal");
        throw Exception("User not found or update failed");
      }

      debugPrint("[SUCCESS] Data user berhasil diupdate");
    } catch (e, stackTrace) {
      debugPrint("[ERROR] Gagal update user: $e");
      debugPrint("[STACKTRACE] $stackTrace");
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
