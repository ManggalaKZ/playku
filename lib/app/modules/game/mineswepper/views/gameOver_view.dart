import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core.dart';

class GameOverScreenMinesweeper extends StatelessWidget {
  final game = Get.find<MinesweeperGame>();
  final controller = Get.find<MinesweeperController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: const Color.fromARGB(159, 0, 0, 0),
      child: Center(
        child: Container(
          height: 270,
          width: 320,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over!\nWaktu terakhir: ${controller.lastTime} detik',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: () {
                    controller.gameRef?.overlays.remove('GameOverOverlay');
                    game.mainLagi();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    "Main Lagi",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: () async {
                    final homeController = Get.find<HomeController>();
                    homeController.userController.loadUserFromPrefs();
                    // Navigasi ke Home
                    Get.offAllNamed(Routes.HOME);
                    controller.resetGame();
                    game.gameTimer.reset();
                    await Future.delayed(Duration(milliseconds: 1200));
                    game.clearGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    "Keluar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
