import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/core.dart';
import 'package:playku/core_game.dart';



class SelectLevelDialog extends StatelessWidget {
  final int indexGame;
  final String title;
  final void Function(int indexGame) onPlay;
  final Rx<GameLevel> selectedLevel;
  final void Function(GameLevel level) onLevelSelected;

  SelectLevelDialog({
    super.key,
    required this.indexGame,
    required this.title,
    required this.onPlay,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  final MinesweeperController minesweeperController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.sawarabiGothic(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Pilih Level",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),

              // Pilihan Level
              Obx(() => Column(
                    children: GameLevel.values.map((level) {
                      bool isSelected = selectedLevel.value == level;

                      return GestureDetector(
                        onTap: () {
                          AudioService.playButtonSound();
                          selectedLevel.value = level;
                          onLevelSelected(level);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.whitePrimary
                                  : Colors.white24,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.secondary.withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              level.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),

              // Tombol
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      AudioService.playButtonSound();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                          fontSize: 16, color: AppColors.whitePrimary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AudioService.playButtonSound();
                      Navigator.of(context).pop();
                      onPlay(indexGame);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whitePrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Mainkan",
                      style: TextStyle(fontSize: 16, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
