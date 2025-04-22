import 'package:flame/components.dart';
import 'package:playku/app/modules/game/memory-game/components/card_component.dart';
import 'package:playku/app/modules/game/memory-game/controllers/memory_game_controller.dart';
import 'dart:math';

class BoardComponent extends PositionComponent with HasGameRef {
  final MemoryGameController controller;
  static const double padding = 20;

  BoardComponent({required this.controller});
  @override
  Future<void> onLoad() async {
    super.onLoad();

    int lengCard = controller.lengCard;

    int columns = (sqrt(lengCard)).round();
    while (lengCard % columns != 0) {
      columns++;
    }
    int rows = lengCard ~/ columns;

    final double cardSize = (gameRef.size.x - 2 * padding) / columns - 10;
    final double boardWidth = (cardSize + 10) * columns;
    final double boardHeight = (cardSize + 10) * rows;

    position = Vector2(
      (gameRef.size.x - boardWidth) / 2,
      (gameRef.size.y - boardHeight) / 2,
    );

    for (int i = 0; i < lengCard; i++) {
      add(CardComponent(
        index: i,
        position: Vector2(
          (i % columns) * (cardSize + 10),
          (i ~/ columns) * (cardSize + 10),
        ),
        size: Vector2(cardSize, cardSize),
        controller: controller,
      ));
    }
  }
}
