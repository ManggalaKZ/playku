import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/modules/game/controller/game_controller.dart';
import 'package:playku/theme.dart';

class HomeGameItem extends StatelessWidget {
  final String title;
  final String thumbnail;
  final BuildContext context;
  final int indexGame;
  final GameController gameController;

  const HomeGameItem({
    Key? key,
    required this.title,
    required this.thumbnail,
    required this.context,
    required this.indexGame,
    required this.gameController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => gameController.showDialogConfirm(context, indexGame, title),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    thumbnail,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.sawarabiGothic(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
