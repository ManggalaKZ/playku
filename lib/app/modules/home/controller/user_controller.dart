import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playku/app/modules/home/controller/frame_controller.dart';
import 'package:playku/core/core.dart';

class UserController extends GetxController {
  var userModel = Rxn<UserModel>();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var namaController = TextEditingController();
  var emailController = TextEditingController();
  final isUploading = false.obs;
  var isLoading = false.obs;

  Future<void> loadUserFromPrefs() async {
    isLoading.value = true;
    try {
      var userDataMap = await SharedPreferenceHelper.getUserData();

      if (userDataMap != null) {
        userModel.value = UserModel.fromJson(userDataMap);

        userModel.refresh();
      } else {}
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(userId, data) async {
    final api = UserService();
    if (passwordController.text.isNotEmpty) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar("Error", "Password tidak cocok");
        return;
      }
      data['password'] = passwordController.text;
    }

    try {
      await api.updateUser(userId!, data);
      final updatedUser = await api.fetchUser(userId);
      userModel.value = UserModel.fromJson(updatedUser);

      await SharedPreferenceHelper.saveUserData(
        userId: userModel.value!.id.toString(),
        point: userModel.value!.point,
        userName: userModel.value!.username,
        userEmail: userModel.value!.email,
        avatar: userModel.value!.avatar ?? "",
        name: userModel.value!.name,
        usedBorderIds: userModel.value!.usedBorderIds,
        ownedBorderIds: userModel.value!.ownedBorderIds,
      );

      Get.back();
      Get.snackbar("Berhasil", "Profil berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e");
    }
  }

  void showEditProfile() {
    final user = userModel.value;
    if (user == null) return;

    usernameController.text = user.username;
    namaController.text = user.name;
    emailController.text = user.email;
    var avatarPath = RxString(user.avatar ?? '');

    passwordController.clear();
    confirmPasswordController.clear();

    Get.dialog(
      EditProfileDialog(
        usernameController: usernameController,
        namaController: namaController,
        emailController: emailController,
        passwordController: passwordController,
        confirmPasswordController: confirmPasswordController,
        avatarPath: avatarPath,
        isUploading: isUploading,
        onCancel: () => Get.back(),
        onSave: () {
          final data = {
            'username': usernameController.text.trim(),
            'name': namaController.text.trim(),
            'email': emailController.text.trim(),
            'avatar': avatarPath.value,
          };
          updateProfile(user.id, data);
          Get.back();
        },
      ),
    );
  }
}
