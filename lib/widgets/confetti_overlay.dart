import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    _particles = List.generate(90, (_) => _Particle(
      x: rand.nextDouble(),
      delay: rand.nextDouble() * 0.3,
      duration: 1.5 + rand.nextDouble() * 2,
      color: confettiColors[rand.nextInt(confettiColors.length)],
      size: 6 + rand.nextDouble() * 6,
      isCircle: rand.nextBool(),
    ));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500))..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(_particles, _ctrl.value),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x, delay, duration, size;
  final Color color;
  final bool isCircle;
  _Particle({required this.x, required this.delay, required this.duration, required this.color, required this.size, required this.isCircle});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress * 4.5 - p.delay) / p.duration).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final x = p.x * size.width;
      final y = -40 + t * (size.height + 80);
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withOpacity(opacity);
      final angle = t * 14;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

