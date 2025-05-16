import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:playku/core/core.dart';


class CardComponent extends PositionComponent with TapCallbacks {
  final int index;
  final MemoryGameController controller;

  CardComponent({
    required this.index,
    required this.controller,
    required Vector2 position,
    required Vector2 size,
  }) {
    this.position = position;
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    final bool isFlipped = controller.cards[index].isFlipped;

    final paint = Paint()
      ..color = isFlipped ? Colors.white : AppColors.secondary;

    final RRect roundedRect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(10), 
    );

    canvas.drawRRect(roundedRect, paint);

    if (isFlipped) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${controller.cards[index].value}', 
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y / 2 - textPainter.height / 2),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    AudioService.playButtonSound();
    if (!controller.cards[index].isFlipped &&
        !controller.cards[index].isMatched) {
      controller.onCardTapped(index);
    }
  }
}
