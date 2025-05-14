import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/models/frame_model.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/theme.dart';

class ChooseFrameDialog extends StatelessWidget {
  final List<FrameModel> ownedframes;
  final String usedFrame;
  final Function(FrameModel) onChoose;

  const ChooseFrameDialog({
    super.key,
    required this.ownedframes,
    required this.usedFrame,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pilih Border Anda",
              style: GoogleFonts.sawarabiGothic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whitePrimary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: ownedframes.length,
                itemBuilder: (context, index) {
                  final frame = ownedframes[index];
                  final bool isUsed = frame.id == usedFrame;

                  return GestureDetector(
                    onTap: () {
                      AudioService.playButtonSound();
                      onChoose(frame);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isUsed
                              ? AppColors.secondary
                              : Colors.grey.shade300,
                          width: isUsed ? 5.0 : 2.0,
                        ),
                        color: const Color.fromARGB(29, 255, 255,
                            255), // Tambahkan warna background transparan
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                            isUsed ? 5.0 : 2.0), // Padding sesuai border
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(frame.imagePath ?? ''),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                debugPrint('Error loading image: $exception');
                              },
                            ),
                          ),
                          child: isUsed
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.secondary.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white, size: 16),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    AudioService.playButtonSound();
                    Get.back();
                  },
                  child: Text(
                    'TUTUP',
                    style: GoogleFonts.sawarabiGothic(
                        color: AppColors.whitePrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
