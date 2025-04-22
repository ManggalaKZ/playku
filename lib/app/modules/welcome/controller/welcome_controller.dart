import 'package:get/get.dart';
import '../../../routes/app_routes.dart';


class WelcomeController extends GetxController {
  void goToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
