import 'package:get/get.dart';
import 'package:playku/app/modules/auth/controller/login_controller.dart';
import 'package:playku/app/modules/home/controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<LoginController>(LoginController());
  }
}
