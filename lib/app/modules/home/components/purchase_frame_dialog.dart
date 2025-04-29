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
    List<FrameModel> sortedFrames = List.from(frames);

    // Urutkan list
    sortedFrames.sort((a, b) {
      final bool aOwned = ownedBorderIds.contains(a.id);
      final bool bOwned = ownedBorderIds.contains(b.id);

      if (aOwned && !bOwned) {
        return 1; // a (owned) diletakkan setelah b (not owned)
      } else if (!aOwned && bOwned) {
        return -1; // a (not owned) diletakkan sebelum b (owned)
      } else if (!aOwned && !bOwned) {
        // Jika keduanya belum dimiliki, urutkan berdasarkan harga (termahal dulu)
        return b.price.compareTo(a.price);
      } else {
        // Jika keduanya sudah dimiliki, urutkan berdasarkan nama (opsional, agar konsisten)
        return a.name.compareTo(b.name);
      }
    });
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
              "Toko Border",
              style: GoogleFonts.sawarabiGothic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "Poin Anda: $userPoints",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.whitePrimary),
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
                  itemCount: sortedFrames.length,
                  itemBuilder: (context, index) {
                    final frame = sortedFrames[index];
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
                              child: Image.network(
                                frame.imagePath,
                                fit: BoxFit.contain,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    // Jika loading selesai, tampilkan gambar
                                    return child;
                                  } else {
                                    // Jika masih loading, tampilkan CircularProgressIndicator
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null, // Tampilkan progress jika memungkinkan
                                        strokeWidth:
                                            2.0, // Atur ketebalan spinner
                                      ),
                                    );
                                  }
                                },
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
                            alreadyOwned
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 30,
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canAfford
                                          ? AppColors.secondary
                                          : Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    onPressed: canAfford
                                        ? () {
                                            _showConfirmationDialog(
                                                context, frame);
                                          }
                                        : null,
                                    child: Text(
                                      canAfford ? "Beli" : "Poin Kurang",
                                      style: GoogleFonts.sawarabiGothic(
                                          color: Colors.white),
                                    ),
                                  )
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
              child: Image.network(
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
