import 'dart:math';
import 'package:flutter/material.dart';

class StarBackground extends StatefulWidget {
  final Widget child;
  const StarBackground({super.key, required this.child});

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();
    final random = Random(42); // fixed seed for consistent layout
    for (int i = 0; i < 120; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 1.8 + 0.4,
        opacity: random.nextDouble() * 0.6 + 0.2,
        phase: random.nextDouble() * 2 * pi,
        speed: random.nextDouble() * 0.8 + 0.4,
      ));
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _StarPainter(_stars, _controller.value),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x, y, size, opacity, phase, speed;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
    required this.speed,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t; // 0.0 – 1.0

  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = (sin(t * 2 * pi * s.speed + s.phase) + 1) / 2;
      final alpha = (s.opacity * (0.4 + twinkle * 0.6) * 255).round();
      final paint = Paint()
        ..color = Color.fromARGB(alpha, 255, 255, 255)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.size * 0.8);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}
