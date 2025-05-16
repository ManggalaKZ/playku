import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/pengaturan/controller/pengaturan_controller.dart';
import 'package:playku/core/theme.dart';

class PengaturanMusik extends StatelessWidget {
  const PengaturanMusik({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PengaturanController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Kelola pengaturan musik atau suara Anda.",
              style: GoogleFonts.sawarabiGothic(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              "Musik",
              style: GoogleFonts.sawarabiGothic(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (controller.bgmVolume.value == 0) {
                          controller.updateBgmVolume(0.5); // Set ke 50%
                        } else {
                          controller.updateBgmVolume(0); // Mute
                        }
                      },
                      child: Icon(
                        controller.bgmVolume.value == 0
                            ? Icons.music_off
                            : Icons.music_note,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.secondary,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                          overlayColor: Colors.blue.withOpacity(0.2),
                          valueIndicatorTextStyle:
                              const TextStyle(color: Colors.white),
                        ),
                        child: Slider(
                          value: controller.bgmVolume.value,
                          min: 0,
                          max: 1,
                          divisions: 100,
                          label:
                              "${(controller.bgmVolume.value * 100).toInt()}%",
                          onChanged: controller.updateBgmVolume,
                          onChangeEnd: controller.playbutton,
                        ),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 24),
            Text(
              "Efek Suara",
              style: GoogleFonts.sawarabiGothic(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (controller.sfxVolume.value == 0) {
                          controller.updateSfxVolume(0.5); // Set ke 50%
                        } else {
                          controller.updateSfxVolume(0); // Mute
                        }
                      },
                      child: Icon(
                        controller.sfxVolume.value == 0
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.secondary,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                          overlayColor: Colors.green.withOpacity(0.2),
                          valueIndicatorTextStyle:
                              const TextStyle(color: AppColors.whitePrimary),
                        ),
                        child: Slider(
                          value: controller.sfxVolume.value,
                          min: 0,
                          max: 1,
                          divisions: 100,
                          label:
                              "${(controller.sfxVolume.value * 100).toInt()}%",
                          onChanged: controller.updateSfxVolume,
                          onChangeEnd: controller.playbutton,
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
