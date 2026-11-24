import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/game_colors.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    final rng = Random(123);
    for (int i = 0; i < 15; i++) {
      _bubbles.add(_Bubble(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 8 + rng.nextDouble() * 20,
        speed: 0.05 + rng.nextDouble() * 0.1,
        color: GameColors.liquidColors[rng.nextInt(GameColors.liquidColors.length)]
            .withOpacity(0.15),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: GameColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _BubblePainter(_bubbles, _controller.value),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Bubble {
  double x;
  double y;
  final double radius;
  final double speed;
  final Color color;

  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double progress;

  _BubblePainter(this.bubbles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      final currentY = ((b.y - progress * b.speed) % 1.2) * size.height - (size.height * 0.1);
      final currentX = b.x * size.width + sin(progress * 2 * pi + b.y * 10) * 15;

      final paint = Paint()
        ..color = b.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(currentX, currentY), b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
