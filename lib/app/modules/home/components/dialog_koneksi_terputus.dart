import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/core/theme.dart';

class KoneksiTerputusDialog extends StatelessWidget {
  const KoneksiTerputusDialog({super.key});

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
            const Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                size: 60, color: AppColors.whitePrimary),
            const SizedBox(height: 16),
            Text(
              'Koneksi Anda Terputus',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.whitePrimary,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mohon periksa kembal koneksi internet Anda.',
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
                  onPressed: () {
                    Get.back();
                  },
                  label: Text(
                    'Oke',
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
