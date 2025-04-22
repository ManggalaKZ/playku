import 'package:get/get.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/data/services/auth_service.dart';
import 'package:playku/app/modules/auth/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService());
    Get.put<LoginController>(LoginController());
    Get.put<AudioService>(AudioService());
  }
}
