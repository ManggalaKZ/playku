import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:playku/theme.dart';

class QuestionComponent extends PositionComponent {
  final String question;

  QuestionComponent(this.question);

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    size = Vector2(gameSize.x * 0.8, gameSize.y * 0.15);

    position = Vector2(
      (gameSize.x - size.x) / 2,
      gameSize.y * 0.2,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = AppColors.secondary;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(12)), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: question,
        style: TextStyle(color: Colors.white, fontSize: size.y * 0.3),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.x - 20);
    textPainter.paint(
      canvas,
      Offset(
          (size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }
}
