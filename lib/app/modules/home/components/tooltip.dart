import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class TooltipController extends GetxController {
  var isTooltipVisible = false.obs;
  OverlayEntry? overlayEntry;

  void showTooltip(BuildContext context, String message, GlobalKey key) {
    if (isTooltipVisible.value) {
      hideTooltip();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      final Offset position = renderBox.localToGlobal(Offset.zero);

      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            GestureDetector(
              onTap: hideTooltip,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              left: position.dx,
              top: position.dy + 24,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      Overlay.of(Get.overlayContext!)?.insert(overlayEntry!);
      isTooltipVisible.value = true;

      Future.delayed(Duration(seconds: 2), hideTooltip);
    });
  }

  void hideTooltip() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
      isTooltipVisible.value = false;
    }
  }
}
