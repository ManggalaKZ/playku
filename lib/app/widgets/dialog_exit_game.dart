import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/theme.dart';

class ExitDialogGame extends StatelessWidget {
  final VoidCallback onExit;
  const ExitDialogGame({required this.onExit, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.exit_to_app,
                size: 60, color: AppColors.whitePrimary),
            const SizedBox(height: 16),
            Text(
              'Keluar Aplikasi?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.whitePrimary,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi PlayKu?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.whitePrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.back(result: false),
                  icon: const Icon(Icons.close),
                  label: const Text('Batal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whitePrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onExit,
                  icon: const Icon(
                    Icons.check,
                    color: AppColors.whitePrimary,
                  ),
                  label: Text(
                    'Keluar',
                    style: GoogleFonts.sawarabiGothic(
                        color: AppColors.whitePrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
