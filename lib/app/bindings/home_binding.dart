import 'package:get/get.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/app/modules/home/controller/leaderboard_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/core.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(UserController());
    Get.put<LeaderboardController>(LeaderboardController());
    Get.put<LoginController>(LoginController());
    Get.put<FrameController>(FrameController());
    Get.put<HomeController>(HomeController());
  }
}
