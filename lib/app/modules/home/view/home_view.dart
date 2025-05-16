import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:playku/app/modules/game/mineswepper/views/gameOver_view.dart';
import 'package:playku/app/modules/pengaturan/view/pengaturan_dialog.dart';
import 'package:playku/app/modules/home/components/widget/home_background.dart';
import 'package:playku/app/modules/home/components/widget/home_game_list.dart';
import 'package:playku/app/modules/home/components/widget/home_header.dart';
import 'package:playku/app/modules/home/components/widget/home_stats.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/app/modules/home/controller/leaderboard_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/app/widgets/dialog_exit.dart';
import 'package:playku/core/core.dart';

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

    return WillPopScope(
      onWillPop: () async {
        final exit = await Get.dialog<bool>(
          const ExitDialog(),
          barrierDismissible: false,
        );
        return exit ?? false;
      },
      child: Scaffold(
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
              top: 55,
              right: 80,
              child: InkWell(
                onTap: () {
                  AudioService.playButtonSound();
                  controller.frameController.showPurchaseFrameDialog();
                },
                child: SvgPicture.asset(
                  'assets/icons/shop.svg',
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 55,
              right: 20,
              child: InkWell(
                onTap: () {
                  Get.dialog(
                    GestureDetector(
                      onTap: () {
                        AudioService.playButtonSound();
                        Get.back();
                      },
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.transparent,
                          ),
                          Center(
                            child: GestureDetector(
                                onTap: () {}, child: PengaturanDialog()),
                          ),
                        ],
                      ),
                    ),
                    barrierDismissible: false,
                  );
                },
                child: SvgPicture.asset(
                  'assets/icons/pengaturan.svg',
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
