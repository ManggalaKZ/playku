import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/services/border_service.dart';
import 'package:playku/app/modules/home/components/choose_frame_dialog.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/core.dart';

class FrameController extends GetxController {
  var frames = <FrameModel>[].obs;
  var usedFrame = Rxn<FrameModel>();
  var isLoadingFrames = false.obs;
  final UserService _userService = UserService();

  Future<void> fetchFrames() async {
    try {
      isLoadingFrames.value = true;

      final List<FrameModel> fetchedFrames = await BorderService.fetchBorders();
      frames.value = fetchedFrames;
      _updateUsedFrame();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data frame: $e");
    } finally {
      isLoadingFrames.value = false;
    }
  }

  void _updateUsedFrame() {
    final userController = Get.find<UserController>();

    if (userController.userModel.value != null && frames.isNotEmpty) {
      final usedId = userController.userModel.value!.usedBorderIds;

      if (usedId != null && usedId.isNotEmpty) {
        try {
          final foundFrame = frames.firstWhereOrNull(
            (frame) => frame.id == usedId,
          );

          if (foundFrame != null) {
            usedFrame.value = foundFrame;
          } else {
            usedFrame.value = null;
          }
        } catch (e) {
          usedFrame.value = null;
        }
      } else {
        usedFrame.value = null;
      }
      usedFrame.refresh();
    } else {
      debugPrint(
          "Cannot update used frame yet. User loaded: ${userController.userModel.value != null}, Frames loaded: ${frames.isNotEmpty}");
    }
  }

  Future<void> purchaseSelectedBorder(FrameModel border) async {
    final userController = Get.find<UserController>();

    if (userController.userModel.value == null) {
      Get.snackbar("Error", "Data user tidak ditemukan.");
      return;
    }

    final userId = userController.userModel.value!.id;
    final borderId = border.id;
    final borderPrice = border.price;

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final updatedUser =
          await _userService.purchaseBorder(userId, borderId, borderPrice);

      Get.back();

      if (updatedUser != null) {
        userController.userModel.value = updatedUser;

        userController.userModel.refresh();

        Get.back();
        Get.snackbar("Berhasil", "Border berhasil dibeli!");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", e.toString().replaceAll('Exception: ', ''));
    }
  }

  void showPurchaseFrameDialog() {
    final userController = Get.find<UserController>();

    if (isLoadingFrames.value) {
      Get.snackbar("Info", "Sedang memuat data frame...");
      return;
    }
    if (frames.isEmpty) {
      Get.snackbar("Info", "Tidak ada frame tersedia saat ini.");
      return;
    }

    Get.dialog(
      PurchaseFrameDialog(
        frames: frames,
        userPoints: userController.userModel.value!.point,
        ownedBorderIds: userController.userModel.value!.ownedBorderIds ?? [],
        onPurchase: (selectedFrame) {
          purchaseSelectedBorder(selectedFrame);
        },
      ),
    );
  }

  void showChooseFrameDialog() {
    final userController = Get.find<UserController>();

    if (userController.userModel.value == null) {
      Get.snackbar("Error", "Data user belum dimuat.");
      return;
    }
    if (isLoadingFrames.value) {
      Get.snackbar("Info", "Sedang memuat data frame...");
      return;
    }

    final List<String> ownedIds =
        userController.userModel.value!.ownedBorderIds ?? [];
    final List<FrameModel> ownedUserFrames =
        frames.where((frame) => ownedIds.contains(frame.id)).toList();

    if (ownedUserFrames.isEmpty) {
      Get.snackbar("Info", "Anda belum memiliki border. Beli di toko!");
      return;
    }

    Get.dialog(
      ChooseFrameDialog(
        ownedframes: ownedUserFrames,
        usedFrame: userController.userModel.value!.usedBorderIds ?? "",
        onChoose: (selectedFrame) {
          useBorder(selectedFrame);
        },
      ),
    );
  }

  Future<void> useBorder(FrameModel selectedFrame) async {
    final userController = Get.find<UserController>();

    if (userController.userModel.value == null) {
      Get.snackbar("Error", "Data user tidak ditemukan.");
      return;
    }

    final userId = userController.userModel.value!.id;
    final borderId = selectedFrame.id;

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      await _userService.updateUsedBorder(userId, borderId);

      userController.userModel.value!.usedBorderIds = borderId;
      userController.userModel.refresh();
      _updateUsedFrame();

      await SharedPreferenceHelper.saveUserData(
        userId: userController.userModel.value!.id.toString(),
        point: userController.userModel.value!.point,
        userName: userController.userModel.value!.username,
        userEmail: userController.userModel.value!.email,
        avatar: userController.userModel.value!.avatar ?? "",
        name: userController.userModel.value!.name,
        ownedBorderIds: userController.userModel.value!.ownedBorderIds ?? [],
        usedBorderIds: userController.userModel.value!.usedBorderIds,
      );

      Get.back();
      Get.snackbar("Berhasil", "Border berhasil diganti!");
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", "Gagal mengganti border: $e");
    }
  }
}
