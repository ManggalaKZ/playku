import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/local/shared_preference_helper.dart';
import 'package:playku/app/modules/pengaturan/controller/pengaturan_controller.dart';
import 'package:playku/core/core.dart';
import 'package:playku/core/theme.dart';

class PengaturanAkun extends StatelessWidget {
  const PengaturanAkun({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PengaturanController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Pengaturan Akun",
            style: GoogleFonts.sawarabiGothic(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Kelola akun Anda atau keluar dari aplikasi.",
                  style: GoogleFonts.sawarabiGothic(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.whitePrimary,
                    size: 24,
                  ),
                  label: const Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.secondary.withOpacity(0.5),
                  ),
                  onPressed: () {
                    AudioService.playButtonSound();
                    controller.showEditProfile();
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: Text(
                    "Keluar",
                    style: GoogleFonts.sawarabiGothic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.secondary.withOpacity(0.5),
                  ),
                  onPressed: () {
                    AudioService.playButtonSound();
                    Get.dialog(
                      AlertDialog(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          "Konfirmasi Keluar",
                          style: GoogleFonts.sawarabiGothic(
                              fontWeight: FontWeight.bold,
                              color: AppColors.whitePrimary),
                        ),
                        content: Text(
                          "yakin ingin keluar dari aplikasi?",
                          style: GoogleFonts.sawarabiGothic(
                              color: AppColors.whitePrimary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              AudioService.playButtonSound();
                              Get.back();
                            },
                            child: Text(
                              "Batal",
                              style: GoogleFonts.sawarabiGothic(
                                color: AppColors.whitePrimary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            onPressed: () async {
                              AudioService.playButtonSound();

                              await SharedPreferenceHelper.clearUserData();
                              Get.offAllNamed(Routes.WELCOME);
                            },
                            child: Text(
                              "Keluar",
                              style: GoogleFonts.sawarabiGothic(
                                  color: AppColors.whitePrimary),
                            ),
                          ),
                        ],
                      ),
                      barrierDismissible: false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
