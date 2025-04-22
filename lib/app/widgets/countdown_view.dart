import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownView extends StatefulWidget {
  final VoidCallback onCountdownFinished;

  const CountdownView({Key? key, required this.onCountdownFinished})
      : super(key: key);

  @override
  _CountdownViewState createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView>
    with SingleTickerProviderStateMixin {
  int _countdown = 3;
  double _scale = 1.0;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = _countdown; i >= 0; i--) {
      if (!mounted) return;
      setState(() {
        _countdown = i;
        _scale = 1.5; 
      });
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _scale = 1.0; 
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    
    if (!mounted) return;
    setState(() {
      _isShaking = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    widget.onCountdownFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54, 
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isShaking
              ? Matrix4.translationValues(
                  (Get.width * 0.01) * (_isShaking ? -1 : 1), 0, 0)
              : Matrix4.identity(),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _scale,
            child: Text(
              _countdown > 0 ? '$_countdown' : 'Mulai!',
              style: GoogleFonts.bangers(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.blueAccent.withOpacity(0.8),
                    offset: Offset(0, 0),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
