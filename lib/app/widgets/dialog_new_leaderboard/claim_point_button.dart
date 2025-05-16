import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/core/theme.dart';

class ClaimPointButton extends StatelessWidget {
  final int? pointTambahan;
  final VoidCallback onPressed;

  const ClaimPointButton({
    Key? key,
    required this.pointTambahan,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Container(
        width: Get.width * 0.29,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Klaim $pointTambahan',
              maxLines: 1,
              style: GoogleFonts.sawarabiGothic(fontSize: 18),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.monetization_on,
              size: 24.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}