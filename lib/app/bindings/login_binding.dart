import 'package:get/get.dart';
import 'package:playku/core.dart';


class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService());
    Get.put<LoginController>(LoginController());
    Get.put<AudioService>(AudioService());
  }
}
