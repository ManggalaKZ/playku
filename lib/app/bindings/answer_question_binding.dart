import 'package:get/get.dart';
import 'package:playku/app/data/services/audio_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put<AnswerQuestionController>(AnswerQuestionController());
    Get.put<AudioService>(AudioService());
  }
}
