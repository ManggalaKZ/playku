import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playku/app/data/models/frame_model.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/pengaturan/view/pengaturan_akun.dart';
import 'package:playku/app/modules/pengaturan/view/pengaturan_border.dart';
import 'package:playku/app/modules/pengaturan/view/pengaturan_musik.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/theme.dart';

class PengaturanController extends GetxController {
  var selectedIndex = 0.obs;
  FrameController frameController = Get.find<FrameController>();
  List<FrameModel> ownedUserFrames = [];
  final userController = Get.find<UserController>();
  var bgmVolume = 1.0.obs;
  var sfxVolume = 1.0.obs;

  @override
  void onInit() {
    AudioService.playBackgroundMusic();
    super.onInit();
    fetchFrames();
    loadSavedVolumes();
  }

  void loadSavedVolumes() async {
    final bgm = await AudioService.loadBgmVolume();
    final sfx = await AudioService.loadSfxVolume();

    bgmVolume.value = bgm;
    sfxVolume.value = sfx;

    AudioService.setBgmVolume(bgm);
    AudioService.setSfxVolume(sfx);
  }

  fetchFrames() {
    final userController = Get.find<UserController>();

    if (userController.userModel.value == null) {
      Get.snackbar("Error", "Data user belum dimuat.");
      return;
    }
    if (frameController.isLoadingFrames.value) {
      Get.snackbar("Info", "Sedang memuat data frame...");
      return;
    }

    final List<String> ownedIds =
        userController.userModel.value!.ownedBorderIds ?? [];
    ownedUserFrames = frameController.frames
        .where((frame) => ownedIds.contains(frame.id))
        .toList();

    if (ownedUserFrames.isEmpty) {
      Get.snackbar("Info", "Anda belum memiliki border. Beli di toko!");
      return;
    }
  }

  void showEditProfile() {
    return userController.showEditProfile();
  }

  void updateBgmVolume(double value) {
    bgmVolume.value = value;
    AudioService.setBgmVolume(value);
    AudioService.saveBgmVolume(value); 
  }

  void updateSfxVolume(double value) {
    sfxVolume.value = value;
    AudioService.setSfxVolume(value);
    AudioService.saveSfxVolume(value); 
  }

  void playbutton(double value) {
    AudioService.playButtonSound();
  }

  Widget buildSettingContent() {
    AudioService.playButtonSound();
    fetchFrames();
    switch (selectedIndex.value) {
      case 0:
        return PengaturanMusik();
      case 1:
        return PengaturanBorder(
          ownedframes: ownedUserFrames,
          usedFrame: userController.userModel.value!.usedBorderIds ?? "",
          onChoose: (selectedFrame) {
            frameController.useBorder(selectedFrame);
          },
        );
      case 2:
        return PengaturanAkun();
      default:
        return PengaturanAkun();
    }
  }
}
