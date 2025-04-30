import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/home/components/widget/home_background.dart';
import 'package:playku/app/modules/home/components/widget/home_game_list.dart';
import 'package:playku/app/modules/home/components/widget/home_header.dart';
import 'package:playku/app/modules/home/components/widget/home_stats.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/app/modules/home/controller/leaderboard_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/core.dart';
import 'package:playku/app/modules/home/components/widget/home_popup_menu.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());
    final LoginController loginController = Get.put(LoginController());
    final UserController userController = Get.put(UserController());
    final FrameController frameController = Get.put(FrameController());
    final LeaderboardController leaderboardController =
        Get.put(LeaderboardController());
    bool tooltipShown = false;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          HomeBackground(context: context, loginController: loginController),
          SingleChildScrollView(
            controller: ScrollController(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                SizedBox(height: 70),
                HomeHeader(
                    userController: userController,
                    frameController: frameController,
                    context: context,
                    tooltipShown: tooltipShown),
                HomeStats(
                  context: context,
                  userController: userController,
                  leaderboardController: leaderboardController,
                ),
                SizedBox(height: 30),
                HomeGameList(gameController: gameController, context: context)
              ],
            ),
          ),
          Positioned(
            top: 45,
            right: 20,
            child: HomePopupMenu(
              menuKey: _menuKey,
              loginController: loginController,
              onLogout: () {
                Get.offAllNamed(Routes.WELCOME);
              },
            ),
          ),
          Positioned(
            top: 45,
            right: 70,
            child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  size: 32,
                  color: AppColors.whitePrimary,
                ),
                onPressed: () {
                  AudioService.playButtonSound();
                  controller.frameController.showPurchaseFrameDialog();
                }),
          ),
          Positioned(
            top: 45,
            left: 40,
            child: IconButton(
                icon: Icon(
                  Icons.border_all,
                  size: 32,
                  color: AppColors.whitePrimary,
                ),
                onPressed: () {
                  AudioService.playButtonSound();
                  controller.frameController.showChooseFrameDialog();
                }),
          ),
        ],
      ),
    );
  }
}
