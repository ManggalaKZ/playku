import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/models/frame_model.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/theme.dart';

class PengaturanBorder extends StatelessWidget {
  final List<FrameModel> ownedframes;
  final String usedFrame;
  final Function(FrameModel) onChoose;

  const PengaturanBorder({
    super.key,
    required this.ownedframes,
    required this.usedFrame,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Pilih Border Anda",
                style: GoogleFonts.sawarabiGothic(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whitePrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Text(
                    "Border yang Anda miliki",
                    style: GoogleFonts.sawarabiGothic(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: ownedframes.length,
                    itemBuilder: (context, index) {
                      final frame = ownedframes[index];
                      final bool isUsed = frame.id == usedFrame;

                      return GestureDetector(
                        onTap: () {
                          onChoose(frame);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isUsed
                                  ? AppColors.secondary
                                  : Colors.grey.shade400,
                              width: isUsed ? 4.0 : 2.0,
                            ),
                            color: Colors.white.withOpacity(0.08),
                            boxShadow: isUsed
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.secondary.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    frame.imagePath ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.white38, size: 40),
                                      );
                                    },
                                  ),
                                ),
                                if (isUsed)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
