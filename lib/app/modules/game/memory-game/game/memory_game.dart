import 'dart:ui';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:playku/core.dart';


class MemoryGame extends FlameGame {
  final MemoryGameController controller = Get.find<MemoryGameController>();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    controller.setGame(this); 
    add(BoardComponent(controller: controller));
  }
  
  @override
  void render(Canvas canvas) {
    final backgroundPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(size.toRect(), backgroundPaint);
    super.render(canvas);
  }

  void gameOver() {
    overlays.add('GameOver');
  }
}
