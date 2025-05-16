import 'package:get/get.dart';
import 'package:playku/core/core.dart';

class MemoryGameBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MemoryGameController>(MemoryGameController());
    Get.put(MemoryGame());
    ;
  }
}
