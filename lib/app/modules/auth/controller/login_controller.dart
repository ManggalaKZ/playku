import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/models/user_model.dart';
import 'package:playku/app/routes/app_routes.dart';
import 'package:playku/theme.dart';

import '../../../data/local/shared_preference_helper.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/audio_service.dart';

class LoginController extends GetxController {
  var userModel = Rxn<UserModel>();
  var isSoundOn = true.obs;
  var isEnglish = true.obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var dummyTrigger = false.obs;

  final AuthService _authService = Get.put(AuthService());
  var usernameController = TextEditingController()..text = 'admin';
  var passwordController = TextEditingController()..text = 'admin';

  @override
  void onInit() {
    super.onInit();
  }

  void toggleSound() {
    AudioService.playButtonSound();
    isSoundOn.value = !isSoundOn.value;
    if (isSoundOn.value) {
      AudioService.resumeBackgroundMusic();
    } else {
      AudioService.pauseBackgroundMusic();
    }
  }

  void toggleLanguage() {
    isEnglish.value = !isEnglish.value;
    String newLang = isEnglish.value ? 'en' : 'id';
    Get.updateLocale(Locale(newLang));
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleDummy() {
    dummyTrigger.value = !dummyTrigger.value;
  }

  Future<void> login() async {
    AudioService.playButtonSound();
    isLoading.value = true;

    String username = usernameController.text;
    String password = passwordController.text;

    var userData = await _authService.login(username, password);
    print("Login Response: $userData");
    isLoading.value = false;

    if (userData != null) {
      userModel.value = userData;
      await SharedPreferenceHelper.saveUserData(
        userId: userData.id,
        point: userData.point,
        userName: userData.username,
        name: userData.name,
        userEmail: userData.email,
        avatar: userData.avatar ??
            "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
      );
      print("user yang disimpan setelah log ${userModel.value!.name}");
      Get.snackbar("Success", "Login berhasil", backgroundColor: AppColors.bg);
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.snackbar("Error", "Username atau password salah");
    }
  }
}
