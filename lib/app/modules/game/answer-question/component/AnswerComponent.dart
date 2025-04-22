import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:playku/app/data/services/audio_service.dart';

class AnswerComponent extends PositionComponent {
  final String text;
  final bool isCorrect;
  final Function(bool) onPressed;
  final int index;

  AnswerComponent({
    required this.text,
    required this.isCorrect,
    required this.onPressed,
    required this.index,
  }) : super(
          size: Vector2(100, 50),
        );

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    size = Vector2(gameSize.x * 0.4, gameSize.y * 0.1);

    double spacingX = gameSize.x * 0.05;
    double spacingY = gameSize.y * 0.02;

    double startX = (gameSize.x - (2 * size.x) - spacingX) / 2;
    double startY = gameSize.y * 0.4;

    int row = index ~/ 2;
    int col = index % 2;

    position = Vector2(
      startX + col * (size.x + spacingX),
      startY + row * (size.y + spacingY),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.blueGrey;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.white, fontSize: size.y * 0.4),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.x - 10);
    textPainter.paint(
      canvas,
      Offset(
          (size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }
}
