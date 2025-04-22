import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/core.dart';


class RegistrasiController extends GetxController {
  var isLoading = false.obs;

  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var namaController = TextEditingController();
  var emailController = TextEditingController();

  void register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = namaController.text.trim();
    final email = emailController.text.trim();

    if ([username, password, confirmPassword, name, email].any((e) => e.isEmpty)) {
      Get.snackbar("Error", "Semua field harus diisi");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Password tidak sama dengan konfirmasi password");
      return;
    }

    isLoading.value = true;

    try {
      await AuthService.registerUser(
        username: username,
        name: name,
        email: email,
        password: password,
      );

      Get.snackbar("Sukses", "Akun berhasil didaftarkan. Silakan login.");
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar("Gagal", e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
