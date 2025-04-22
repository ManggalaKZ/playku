import 'package:get/get.dart';
import 'package:playku/app/modules/game/mineswepper/controllers/minesweeper_controller.dart';

class MinesweeperBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MinesweeperController>(MinesweeperController());
  }
}
