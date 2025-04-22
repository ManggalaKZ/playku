import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core.dart';


class PurchaseFrameDialog {
  static void show({
    required List<FrameModel> frames,
    required Function(FrameModel) onBuy,
  }) {
    Get.dialog(StatefulBuilder(
      builder: (context, setState) => Center(
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.whitePrimary,
          child: Container(
            constraints: BoxConstraints(maxHeight: Get.height * 0.7),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Bingkai',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: frames.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final frame = frames[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              frame.imagePath,
                              width: 80,
                              height: 80,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              frame.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${frame.price} poin'),
                            const SizedBox(height: 0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back(); // Tutup dialog
                                  onBuy(frame);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                child: const Text('Beli'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutupsss'),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
