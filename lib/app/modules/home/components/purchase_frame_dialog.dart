import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/models/frame_model.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/theme.dart';

class PurchaseFrameDialog extends StatelessWidget {
  final List<FrameModel> frames;
  final int userPoints;
  final List<String> ownedBorderIds;
  final Function(FrameModel) onPurchase;

  const PurchaseFrameDialog({
    super.key,
    required this.frames,
    required this.userPoints,
    required this.ownedBorderIds,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Toko Border",
              style: GoogleFonts.sawarabiGothic(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Poin Anda: $userPoints",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.5,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: frames.length,
                  itemBuilder: (context, index) {
                    final frame = frames[index];
                    final bool canAfford = userPoints >= frame.price;
                    final bool alreadyOwned = ownedBorderIds.contains(frame.id);

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                frame.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                        child: Icon(Icons.error,
                                            size: 30, color: Colors.grey)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              frame.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('${frame.price} Point'),
                            const SizedBox(height: 4),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: alreadyOwned
                                    ? Colors.grey
                                    : (canAfford
                                        ? AppColors.secondary
                                        : Colors.redAccent),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              onPressed: alreadyOwned || !canAfford
                                  ? null
                                  : () {
                                      _showConfirmationDialog(context, frame);
                                    },
                              child: Text(
                                alreadyOwned
                                    ? "Dimiliki"
                                    : (canAfford ? "Beli" : "Poin Kurang"),
                                style: GoogleFonts.sawarabiGothic(
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  AudioService.playButtonSound();
                  Get.back();
                },
                child: Text(
                  'Tutup',
                  style:
                      GoogleFonts.sawarabiGothic(color: AppColors.whitePrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, FrameModel frame) {
    AudioService.playButtonSound();
    Get.defaultDialog(
        title: "Konfirmasi Pembelian",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset(
                frame.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.grey, size: 50);
                },
              ),
            ),
          ],
        ),
        textConfirm: "${frame.price} Poin",
        textCancel: "Batal",
        confirmTextColor: Colors.white,
        cancelTextColor: AppColors.secondary,
        buttonColor: AppColors.secondary,
        radius: 12,
        onConfirm: () {
          AudioService.playButtonSound();
          Get.back();
          onPurchase(frame);
        },
        onCancel: () {
          AudioService.playButtonSound();
        });
  }
}
