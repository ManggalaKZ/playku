import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:playku/app/modules/game/mineswepper/models/tile_model.dart';
import 'package:playku/theme.dart';

class TileComponent extends PositionComponent with TapCallbacks {
  late TileModel tile;
  final Function(TileModel) onTileTapped;
  final Function(TileModel) onTileLongPressed;

  TileComponent({
    required this.tile,
    required this.onTileTapped,
    required this.onTileLongPressed,
  });

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    onTileTapped(tile);
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    super.onLongTapDown(event);
    onTileLongPressed(tile);
  }

  set updateTile(TileModel newTile) {
    tile = newTile;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = tile.isOpened
          ? (tile.isBomb ? Colors.red : AppColors.bg)
          : AppColors.secondary;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)), paint);

    if (tile.isOpened && !tile.isBomb) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: tile.adjacentBombs > 0 ? '${tile.adjacentBombs}' : '',
          style: TextStyle(color: Colors.black, fontSize: size.y * 0.4),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.x - 10);
      textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2),
      );
    }

    if (tile.isBomb && tile.isOpened) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "💣",
          style: TextStyle(color: Colors.black, fontSize: size.y * 0.4),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.x - 10);
      textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2),
      );
    }

    if (!tile.isOpened && tile.isFlagged) {
      final flagPainter = TextPainter(
        text: TextSpan(
          text: '🚩',
          style: TextStyle(color: Colors.red, fontSize: size.y * 0.5),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      flagPainter.layout(maxWidth: size.x);
      flagPainter.paint(
        canvas,
        Offset((size.x - flagPainter.width) / 2,
            (size.y - flagPainter.height) / 2),
      );
    }
  }
}
