import 'package:get/get.dart';
import 'package:playku/app/data/services/audio_service.dart';
import 'package:playku/app/modules/game/memory-game/controllers/memory_game_controller.dart';
import 'package:playku/app/modules/game/memory-game/game/memory_game.dart';

class MemoryGameBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MemoryGameController>(MemoryGameController());
    Get.put(MemoryGame());
    ;
  }
}
