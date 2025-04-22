import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/models/leaderboard_model.dart';
import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'package:playku/app/data/services/api_service.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/widgets/image_picker.dart';
import 'package:playku/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';

class HomeController extends GetxController {
  var userModel = Rxn<UserModel>();
  var leaderboard = <Leaderboard>[].obs;
  var isLoading = false.obs;
  var isLoadingui = false.obs;
  var userTopLeaderboard = Rxn<Leaderboard>();
  var userLeaderboardRank = 0.obs;
  var selectedGameId = (-1).obs;
  var selectedLevel = "Semua".obs;
  Map<String, Map<String, List<Leaderboard>>> groupedLeaderboard = {};
  var filteredLeaderboard = <Leaderboard>[].obs;
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var namaController = TextEditingController();
  var emailController = TextEditingController();
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromPrefs();
    loadLeaderboard();
  }

  String cekPoint() {
    if ((userModel.value?.point ?? 0) == 0) {
      return "Main dulu";
    } else {
      return "${userModel.value?.point}";
    }
  }

  String cekLeaderboard() {
    if ((userLeaderboardRank.value) == -1) {
      return "Main dulu";
    } else {
      return "#${userLeaderboardRank.value}";
    }
  }

  Future<void> loadUserFromPrefs() async {
    var userData = await SharedPreferenceHelper.getUserData();

    if (userData != null) {
      userModel.value = UserModel(
        point: userData["point"] ?? 0,
        id: userData["id"] ?? 0,
        username: userData["username"] ?? "",
        name: userData["name"] ?? "",
        email: userData["email"] ?? "",
        avatar: userData["avatar"] ?? "",
      );

      print("User berhasil dimuat: ${userModel.value!.id}");
      await Future.delayed(Duration.zero);
      userModel.refresh();
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      isLoadingui.value = true;
      leaderboard.value = await AuthService.getLeaderboardAll();
      filterUserTopLeaderboard();
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoadingui.value = false;
    }
  }

  void filterUserTopLeaderboard() {
    if (userModel.value == null) {
      print("DEBUG: UserModel kosong, tidak bisa filter leaderboard.");
      return;
    }

    final userId = userModel.value!.id;

    Leaderboard? bestLeaderboard;
    int bestRank = -1;

    // Loop semua kombinasi gameId + level
    final gameLevelGroups =
        leaderboard.map((e) => {'gameId': e.gameId, 'level': e.level}).toSet();

    for (var group in gameLevelGroups) {
      final gameId = group['gameId']!;
      final level = group['level']!;

      final filtered = leaderboard
          .where((e) => e.gameId == gameId && e.level == level)
          .toList();

      // Urutkan: score tertinggi, timePlay tercepat
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
        print(
            "DEBUG: Ditemukan rank $currentRank di Game $gameId Level $level");

        // Simpan jika ini rank terbaik (rank paling kecil)
        if (bestRank == -1 || currentRank < bestRank) {
          bestRank = currentRank;
          bestLeaderboard = filtered[userIndex];
        }
      }
    }

    if (bestLeaderboard != null) {
      userTopLeaderboard.value = bestLeaderboard;
      userLeaderboardRank.value = bestRank;
      print(
          "✅ Rank terbaik user: $bestRank dari gameId ${bestLeaderboard.gameId} level ${bestLeaderboard.level}");
    } else {
      userTopLeaderboard.value = null;
      userLeaderboardRank.value = -1;
      print("DEBUG: User tidak masuk top 3 leaderboard mana pun.");
    }
  }

  void ontap() {
    AudioService.playButtonSound();
    loadLeaderboard();
    showLeaderboard();
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

    // Sort tiap group berdasarkan waktu tercepat
    groupedLeaderboard.forEach((game, levels) {
      levels.forEach((level, list) {
        list.sort((a, b) => a.timePlay.compareTo(b.timePlay));
      });
    });
  }

  Widget _buildRankBadge(int index) {
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

  Widget _buildGameFilterButton(int gameId, String label, int selectedId) {
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

  void showLeaderboard() {
    filterLeaderboard();
    groupLeaderboardByGameAndLevel();

    Get.dialog(
      Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black.withOpacity(0.4),
          child: Container(
            width: Get.width * 0.95,
            height: Get.height * 0.6,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  "🏆 Leaderboard",
                  style: GoogleFonts.sawarabiGothic(
                    fontSize: 24,
                    color: Colors.amberAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: ScrollController(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildGameFilterButton(
                            -1, "Semua", selectedGameId.value),
                        _buildGameFilterButton(
                            0, "Math Metrix", selectedGameId.value),
                        _buildGameFilterButton(
                            1, "Memory Game", selectedGameId.value),
                        _buildGameFilterButton(
                            2, "MineSweeper", selectedGameId.value),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // 🔹 List Leaderboard (Scrollable)
                Expanded(
                  child: Obx(() {
                    if (isLoading.value) {
                      return Center(
                        child: Text(
                          "⏳ Memuat...",
                          style: GoogleFonts.sawarabiGothic(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    if (filteredLeaderboard.isEmpty) {
                      return Center(
                        child: Text(
                          "Belum ada data leaderboard.",
                          style: GoogleFonts.sawarabiGothic(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupedLeaderboard.entries.map((gameEntry) {
                          final gameTitle = gameEntry.key;
                          final levels = gameEntry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gameTitle,
                                style: GoogleFonts.sawarabiGothic(
                                  fontSize: 16,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...levels.entries.map((levelEntry) {
                                final level = levelEntry.key;
                                final topEntries =
                                    levelEntry.value.take(3).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Level: $level",
                                      style: GoogleFonts.sawarabiGothic(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    ...topEntries.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var e = entry.value;

                                      bool isCurrentUser = e.username ==
                                          userModel.value?.username;

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isCurrentUser
                                              ? Colors.amber.shade100
                                              : Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            _buildRankBadge(index),
                                            const SizedBox(width: 8),
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  Colors.deepPurple.shade300,
                                              backgroundImage:
                                                  e.avatar.isNotEmpty
                                                      ? NetworkImage(e.avatar)
                                                      : null,
                                              child: e.avatar.isEmpty
                                                  ? Text(
                                                      e.username[0]
                                                          .toUpperCase(),
                                                      style: GoogleFonts
                                                          .sawarabiGothic(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isCurrentUser
                                                        ? "Anda"
                                                        : e.username,
                                                    // "haloooasdasdasdasdasdajbsfkajsbfkjasbf",
                                                    style: GoogleFonts
                                                        .sawarabiGothic(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isCurrentUser
                                                          ? Colors.black
                                                          : Colors
                                                              .grey.shade800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        e.played_at,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isCurrentUser
                                                              ? Colors
                                                                  .grey.shade800
                                                              : Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "${e.timePlay} detik",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isCurrentUser
                                                    ? Colors.grey.shade800
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // 🔹 Tombol Tutup (Tidak Scroll)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AudioService.playButtonSound();
                      Get.back();
                    },
                    icon: Icon(Icons.close, color: Colors.white),
                    label: Text(
                      "TUTUP",
                      style: GoogleFonts.sawarabiGothic(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          )),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
    );
  }

  void filterLeaderboard() {
    final all = leaderboard; // Semua data awal
    List<Leaderboard> filtered = [];

    if (selectedGameId.value == -1 && selectedLevel.value == "Semua") {
      filtered = all;
    } else if (selectedGameId.value == -1) {
      // Filter by level only
      filtered = all.where((e) => e.level == selectedLevel.value).toList();
    } else {
      // Filter by both game and level
      filtered = all.where((e) => e.gameId == selectedGameId.value).toList();
    }

    filteredLeaderboard.assignAll(filtered);
    groupLeaderboardByGameAndLevel(); // Update groupedLeaderboard sesuai filter
  }

  void showEditProfile() {
    final user = userModel.value;
    if (user == null) return;

    usernameController.text = user.username;
    namaController.text = user.name;
    emailController.text = user.email;
    var avatarPath = RxString(user.avatar ?? '');

    passwordController.clear();
    confirmPasswordController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Profil",
                  style: GoogleFonts.sawarabiGothic(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Username
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Nama
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Konfirmasi Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Avatar
                Obx(() => QImagePicker(
                      label: "Foto Profil",
                      value: avatarPath.value,
                      onChanged: (path) {
                        avatarPath.value = path;
                        print("[DEBUG] Avatar terpilih: $path");
                      },
                    )),
                const SizedBox(height: 16),

                // Tombol Simpan dan Batal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AudioService.playButtonSound();
                          Get.back();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Batal"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isUploading.value
                                ? null // Disable tombol saat upload
                                : () {
                                    AudioService.playButtonSound();
                                    final data = {
                                      'username':
                                          usernameController.text.trim(),
                                      'name': namaController.text.trim(),
                                      'email': emailController.text.trim(),
                                      'avatar': avatarPath.value,
                                    };
                                    updateProfile(user.id, data);
                                    Get.back();
                                  },
                            icon: const Icon(
                              Icons.save,
                              color: AppColors.whitePrimary,
                            ),
                            label: const Text("Simpan"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateProfile(userId, data) async {
    final api = AuthService();
    if (passwordController.text.isNotEmpty) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar("Error", "Password tidak cocok");
        return;
      }
      data['password'] = passwordController.text;
    }

    try {
      await api.updateUser(userId!, data);
      final updatedUser = await api.fetchUser(userId);
      userModel.value = UserModel.fromJson(updatedUser);

      await SharedPreferenceHelper.saveUserData(
        userId: userModel.value!.id.toString(),
        point: userModel.value!.point,
        userName: userModel.value!.username,
        userEmail: userModel.value!.email,
        avatar: userModel.value!.avatar ?? "",
        name: userModel.value!.name,
      );

      Get.back();
      Get.snackbar("Berhasil", "Profil berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e");
    }
  }
}
