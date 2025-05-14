import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/home/components/dialog_koneksi_terputus.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/app/modules/home/controller/leaderboard_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/core.dart';

class HomeController extends GetxController {
  late UserController userController;
  late LeaderboardController leaderboardController;
  late FrameController frameController;

  @override
  void onInit() {
    super.onInit();
    userController = Get.find<UserController>();
    leaderboardController = Get.find<LeaderboardController>();
    frameController = Get.find<FrameController>();

    loadUserFromPrefs().then((_) {
      fetchFrames();
    });
    loadLeaderboard();
  }

  @override
  void onReady() {
    super.onReady();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      debugPrint('Koneksi internet terputus');
      Get.dialog(KoneksiTerputusDialog());
    }
  }

  void reloadHome() {
    super.onInit();
    userController = Get.find<UserController>();
    leaderboardController = Get.find<LeaderboardController>();
    frameController = Get.find<FrameController>();

    loadUserFromPrefs().then((_) {
      fetchFrames();
    });
    loadLeaderboard();
  }

  Future<void> loadUserFromPrefs() async {
    userController.loadUserFromPrefs();
  }

  Future<void> fetchFrames() async {
    frameController.fetchFrames();
  }

  Future<void> loadLeaderboard() async {
    leaderboardController.loadLeaderboard();
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
