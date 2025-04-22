import 'package:get/get.dart';
import 'package:playku/core.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    print("Splash Screen dijalankan");
    super.onInit();
    navigateToNextPage();
  }

  void navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 3));

    var userData = await SharedPreferenceHelper.getUserData();

    if (userData != null) {
      print("User ditemukan: ${userData['username']}");
      Get.offNamed(Routes.HOME);
    } else {
      print("User tidak ditemukan, ke WelcomeView");
      Get.offNamed(Routes.WELCOME); 
    }
  }
}
