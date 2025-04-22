import 'package:flame/components.dart';
import 'package:get/get.dart';


class GameTimerComponent extends PositionComponent {
  final RxBool isPaused;
  late Timer _timer;
  int _elapsedTime = 0;
  bool _isStarted = false;

  GameTimerComponent({
    required this.isPaused,
    required void Function(String formattedTime) onTick,
  }) {
    _timer = Timer(1, onTick: () => _updateTime(onTick), repeat: true);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    size = Vector2(gameSize.x * 0.8, gameSize.y * 0.15);

    position = Vector2(
      (gameSize.x - size.x) / 2,
      gameSize.y * 0.2,
    );
  }

  void _updateTime(void Function(String) onTick) {
    if (!isPaused.value) {
      _elapsedTime++;
      final minutes = (_elapsedTime ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedTime % 60).toString().padLeft(2, '0');
      onTick('$minutes:$seconds');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isStarted && _timer.isRunning()) {
      _timer.update(dt);
    }
  }

  void start() {
    _elapsedTime = 0;
    _isStarted = true;
    _timer.start();
  }

  void stop() {
    _timer.stop();
    _isStarted = false;
  }

  void reset() {
    _elapsedTime = 0;
    _timer.stop();
    _timer.start();
  }

  bool get isRunning => _timer.isRunning();
}
