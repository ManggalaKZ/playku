import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/services/border_service.dart';
import 'package:playku/app/modules/home/components/choose_frame_dialog.dart';
import 'package:playku/core.dart';

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
  var frames = <FrameModel>[].obs;
  var usedFrame = Rxn<FrameModel>();
  var isLoadingFrames = false.obs;
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    loadUserFromPrefs().then((_) {
      fetchFrames();
    });
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
    isLoading.value = true;
    try {
      var userDataMap = await SharedPreferenceHelper.getUserData();

      if (userDataMap != null) {
        userModel.value = UserModel.fromJson(userDataMap);

        userModel.refresh();
      } else {}
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

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
    if (userModel.value == null) {
      return;
    }

    final userId = userModel.value!.id;

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

    groupedLeaderboard.forEach((game, levels) {
      levels.forEach((level, list) {
        list.sort((a, b) => a.timePlay.compareTo(b.timePlay));
      });
    });
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
      EditProfileDialog(
        usernameController: usernameController,
        namaController: namaController,
        emailController: emailController,
        passwordController: passwordController,
        confirmPasswordController: confirmPasswordController,
        avatarPath: avatarPath,
        isUploading: isUploading,
        onCancel: () => Get.back(),
        onSave: () {
          final data = {
            'username': usernameController.text.trim(),
            'name': namaController.text.trim(),
            'email': emailController.text.trim(),
            'avatar': avatarPath.value,
          };
          updateProfile(user.id, data);
          Get.back();
        },
      ),
    );
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

  Future<void> updateProfile(userId, data) async {
    final api = UserService();
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
        usedBorderIds: userModel.value!.usedBorderIds,
        ownedBorderIds: userModel.value!.ownedBorderIds,
      );

      Get.back();
      Get.snackbar("Berhasil", "Profil berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e");
    }
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

  Future<void> fetchFrames() async {
    try {
      isLoadingFrames.value = true;

      final List<FrameModel> fetchedFrames = await BorderService.fetchBorders();
      frames.value = fetchedFrames;
      _updateUsedFrame();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data frame: $e");
    } finally {
      isLoadingFrames.value = false;
    }
  }

  void _updateUsedFrame() {
    if (userModel.value != null && frames.isNotEmpty) {
      final usedId = userModel.value!.usedBorderIds;

      if (usedId != null && usedId.isNotEmpty) {
        try {
          final foundFrame = frames.firstWhereOrNull(
            (frame) => frame.id == usedId,
          );

          if (foundFrame != null) {
            usedFrame.value = foundFrame;
          } else {
            usedFrame.value = null;
          }
        } catch (e) {
          usedFrame.value = null;
        }
      } else {
        usedFrame.value = null;
      }
      usedFrame.refresh();
    } else {
      print(
          "Cannot update used frame yet. User loaded: ${userModel.value != null}, Frames loaded: ${frames.isNotEmpty}");
    }
  }

  Future<void> purchaseSelectedBorder(FrameModel border) async {
    if (userModel.value == null) {
      Get.snackbar("Error", "Data user tidak ditemukan.");
      return;
    }

    final userId = userModel.value!.id;
    final borderId = border.id;
    final borderPrice = border.price;

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final updatedUser =
          await _userService.purchaseBorder(userId, borderId, borderPrice);

      Get.back();

      if (updatedUser != null) {
        userModel.value = updatedUser;

        userModel.refresh();

        Get.back();
        Get.snackbar("Berhasil", "Border berhasil dibeli!");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", e.toString().replaceAll('Exception: ', ''));
    }
  }

  void showPurchaseFrameDialog() {
    if (isLoadingFrames.value) {
      Get.snackbar("Info", "Sedang memuat data frame...");
      return;
    }
    if (frames.isEmpty) {
      Get.snackbar("Info", "Tidak ada frame tersedia saat ini.");
      return;
    }

    Get.dialog(
      PurchaseFrameDialog(
        frames: frames,
        userPoints: userModel.value!.point,
        ownedBorderIds: userModel.value!.ownedBorderIds ?? [],
        onPurchase: (selectedFrame) {
          purchaseSelectedBorder(selectedFrame);
        },
      ),
    );
  }

  void showChooseFrameDialog() {
    if (userModel.value == null) {
      Get.snackbar("Error", "Data user belum dimuat.");
      return;
    }
    if (isLoadingFrames.value) {
      Get.snackbar("Info", "Sedang memuat data frame...");
      return;
    }

    final List<String> ownedIds = userModel.value!.ownedBorderIds ?? [];
    final List<FrameModel> ownedUserFrames =
        frames.where((frame) => ownedIds.contains(frame.id)).toList();

    if (ownedUserFrames.isEmpty) {
      Get.snackbar("Info", "Anda belum memiliki border. Beli di toko!");
      return;
    }

    Get.dialog(
      ChooseFrameDialog(
        ownedframes: ownedUserFrames,
        usedFrame: userModel.value!.usedBorderIds ?? "",
        onChoose: (selectedFrame) {
          useBorder(selectedFrame);
        },
      ),
    );
  }

  Future<void> useBorder(FrameModel selectedFrame) async {
    if (userModel.value == null) {
      Get.snackbar("Error", "Data user tidak ditemukan.");
      return;
    }

    final userId = userModel.value!.id;
    final borderId = selectedFrame.id;

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      await _userService.updateUsedBorder(userId, borderId);

      userModel.value!.usedBorderIds = borderId;
      userModel.refresh();
      _updateUsedFrame();

      await SharedPreferenceHelper.saveUserData(
        userId: userModel.value!.id.toString(),
        point: userModel.value!.point,
        userName: userModel.value!.username,
        userEmail: userModel.value!.email,
        avatar: userModel.value!.avatar ?? "",
        name: userModel.value!.name,
        ownedBorderIds: userModel.value!.ownedBorderIds ?? [],
        usedBorderIds: userModel.value!.usedBorderIds,
      );

      Get.back();
      Get.back();
      Get.snackbar("Berhasil", "Border berhasil diganti!");
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", "Gagal mengganti border: $e");
    }
  }

}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
