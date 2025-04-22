import 'package:get/get.dart';
import 'package:playku/app/modules/auth/controller/registrasi_controller.dart';

class RegistrasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrasiController>(() => RegistrasiController());
  }
}
