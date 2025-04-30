import 'dart:convert';
import 'package:get/get.dart';
import 'package:playku/app/data/services/point_service.dart';
import 'package:playku/app/modules/home/controller/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardPointService {
  static int? calculatePoint(int? newRankIndex) {
    if (newRankIndex == null) return null;
    int rank = newRankIndex + 1;
    if (rank == 1) {
      return 100;
    } else if (rank == 2) {
      return 50;
    } else {
      return 25;
    }
  }

  static Future<void> addPointUser(int? pointTambahan) async {
    HomeController homeController = Get.find<HomeController>();
    if (homeController.userController.userModel.value == null) {
      print("Error: userModel.value is null");
      return;
    }
    if (pointTambahan == null) {
      print("Error: pointTambahan is null");
      return;
    }
    int? newPoint = await PointService.updateUserPoint(
        homeController.userController.userModel.value!.id, pointTambahan);
    if (newPoint != null) {
      homeController.userController.userModel.value =
          homeController.userController.userModel.value!.copyWith(point: newPoint);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'user', jsonEncode(homeController.userController.userModel.value!.toJson()));
      homeController.userController.loadUserFromPrefs();
      homeController.userController.userModel.refresh();
      homeController.leaderboardController.loadLeaderboard();
    }
  }
}
