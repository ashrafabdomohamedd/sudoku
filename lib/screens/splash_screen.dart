import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _tileController;
  late AnimationController _fadeController;
  int _countdown = 3;
  Timer? _timer;

  final _numbers = [5, 3, 7, 6, 1, 9, 8, 4, 2];

  @override
  void initState() {
    super.initState();
    _tileController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _fadeController.forward();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _tileController.dispose();
    _fadeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -1),
            end: Alignment(0.5, 1),
            colors: [Color(0xFF080B20), Color(0xFF111535), Color(0xFF0D1128)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grid of tiles
              AnimatedBuilder(
                animation: _tileController,
                builder: (context, _) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(9, (i) {
                      final delay = i * 0.1 / 1.2;
                      final t = ((_tileController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                      final curve = Curves.elasticOut.transform(t);
                      return Transform.scale(
                        scale: curve,
                        child: Transform.rotate(
                          angle: (1 - t) * -pi,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0x594F6EF7), Color(0x59A855F7)],
                              ),
                              border: Border.all(color: const Color(0x734F6EF7), width: 1.5),
                              boxShadow: [BoxShadow(color: const Color(0x404F6EF7), blurRadius: 18)],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${_numbers[i]}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [Shadow(color: Color(0xE68CA0FF), blurRadius: 16)],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 28),
              // Logo
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(_fadeController),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6A8FFF), Color(0xFFC084FC), Color(0xFFF471B5)],
                        ).createShader(bounds),
                        child: const Text(
                          'Sudoku',
                          style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'THINK · SOLVE · WIN',
                        style: TextStyle(fontSize: 12, color: Color(0x66FFFFFF), letterSpacing: 3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Loading dots
              _PulseDots(),
              const SizedBox(height: 28),
              Text(
                _countdown > 0 ? '$_countdown seconds…' : '',
                style: const TextStyle(fontSize: 12, color: Color(0x40FFFFFF), letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDots extends StatefulWidget {
  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value - i * 0.14).clamp(0.0, 1.0);
            final scale = 1.0 + 0.35 * sin(phase * pi);
            final opacity = 0.2 + 0.8 * sin(phase * pi).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x40FFFFFF),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

