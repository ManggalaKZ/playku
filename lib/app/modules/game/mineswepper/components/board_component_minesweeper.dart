import 'package:flame/components.dart';
import 'package:get/get.dart';
import 'package:playku/core/core.dart';


class BoardComponentMinesweeper extends PositionComponent with HasGameRef {
  final controller = Get.find<MinesweeperController>();
  final double padding = 4.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = gameRef.size;

    final tileSize =
        (size.x - (controller.cols + 1) * padding) / controller.cols;
    final boardWidth =
        controller.cols * tileSize + (controller.cols - 1) * padding;
    final boardHeight =
        controller.rows * tileSize + (controller.rows - 1) * padding;

    position = Vector2(
      (gameRef.size.x - boardWidth) / 2,
      (gameRef.size.y - boardHeight) / 2,
    );

    for (int row = 0; row < controller.rows; row++) {
      for (int col = 0; col < controller.cols; col++) {
        final tile = controller.tiles[row][col];
        final tileComponent = TileComponent(
          tile: tile,
          onTileTapped: (_) {
            final context = Get.context;
            if (context != null) {
              controller.onTileTapped(row, col, context);
            } else {
              // Optionally handle the null context case, e.g., log or ignore
            }
          },
          onTileLongPressed: (_) => controller.toggleFlag(row, col),
        )
          ..position =
              Vector2(col * (tileSize + padding), row * (tileSize + padding))
          ..size = Vector2(tileSize, tileSize);

        add(tileComponent);

        controller.tileComponents['$row,$col'] = tileComponent;
      }
    }
  }
}
