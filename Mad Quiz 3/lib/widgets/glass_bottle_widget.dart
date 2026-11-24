import 'package:flutter/material.dart';
import '../models/bottle.dart';
import '../utils/game_colors.dart';

class GlassBottleWidget extends StatefulWidget {
  final Bottle bottle;
  final bool isSelected;
  final bool isHintFrom;
  final bool isHintTo;
  final VoidCallback onTap;
  final double width;
  final double height;

  const GlassBottleWidget({
    super.key,
    required this.bottle,
    required this.isSelected,
    this.isHintFrom = false,
    this.isHintTo = false,
    required this.onTap,
    this.width = 54.0,
    this.height = 160.0,
  });

  @override
  State<GlassBottleWidget> createState() => _GlassBottleWidgetState();
}

class _GlassBottleWidgetState extends State<GlassBottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          widget.isSelected ? -28.0 : 0.0,
          0,
        ),
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _BottlePainter(
                bottle: widget.bottle,
                isSelected: widget.isSelected,
                isHintFrom: widget.isHintFrom,
                isHintTo: widget.isHintTo,
                pulse: _pulseController.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final Bottle bottle;
  final bool isSelected;
  final bool isHintFrom;
  final bool isHintTo;
  final double pulse;

  _BottlePainter({
    required this.bottle,
    required this.isSelected,
    required this.isHintFrom,
    required this.isHintTo,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cornerRadius = w * 0.42;
    final lipH = h * 0.04;
    final lipOverhang = w * 0.10;

    // Tube Body Path (U-shaped test tube)
    final bodyPath = Path()
      ..moveTo(-lipOverhang, lipH)
      ..lineTo(0, lipH)
      ..lineTo(0, h - cornerRadius)
      ..arcToPoint(
        Offset(w, h - cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      )
      ..lineTo(w, lipH)
      ..lineTo(w + lipOverhang, lipH)
      ..lineTo(w + lipOverhang, 0)
      ..lineTo(-lipOverhang, 0)
      ..close();

    // Inner Tube Clip Path (for liquid inside)
    final innerPath = Path()
      ..moveTo(2, lipH + 2)
      ..lineTo(2, h - cornerRadius)
      ..arcToPoint(
        Offset(w - 2, h - cornerRadius),
        radius: Radius.circular(cornerRadius - 2),
        clockwise: false,
      )
      ..lineTo(w - 2, lipH + 2)
      ..close();

    // 1. Draw Glass Background (Semi-transparent inner fill)
    final glassBgPaint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, glassBgPaint);

    // 2. Draw Liquid Layers
    canvas.save();
    canvas.clipPath(innerPath);

    final playableHeight = h - lipH - 6;
    final segmentHeight = playableHeight / bottle.capacity;

    for (int i = 0; i < bottle.colors.length; i++) {
      final colorIdx = bottle.colors[i];
      final mainColor = GameColors.liquidColors[colorIdx % GameColors.liquidColors.length];
      final darkColor = GameColors.liquidDarkColors[colorIdx % GameColors.liquidDarkColors.length];

      final topY = h - (i + 1) * segmentHeight;
      final bottomY = h - i * segmentHeight;

      final segmentRect = Rect.fromLTRB(0, topY, w, bottomY);

      // Liquid Gradient
      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [mainColor, darkColor],
        ).createShader(segmentRect);

      canvas.drawRect(segmentRect, liquidPaint);

      // Liquid surface highlight line on top of each block
      final surfacePaint = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(2, topY), Offset(w - 2, topY), surfacePaint);
    }
    canvas.restore();

    // 3. Draw Selected / Hint Glow Outline
    if (isSelected || isHintFrom || isHintTo || bottle.isSolved) {
      Color glowColor;
      if (isSelected) {
        glowColor = GameColors.accentCyan;
      } else if (isHintFrom) {
        glowColor = GameColors.yellow;
      } else if (isHintTo) {
        glowColor = GameColors.green;
      } else {
        glowColor = const Color(0xFF00FF88); // Solved green glow
      }

      final glowBorderPaint = Paint()
        ..color = glowColor.withOpacity(0.4 + pulse * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 4.0 : 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

      canvas.drawPath(bodyPath, glowBorderPaint);
    }

    // 4. Draw Glass Tube Border
    final glassBorderPaint = Paint()
      ..color = isSelected ? GameColors.accentCyan : GameColors.bottleGlassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(bodyPath, glassBorderPaint);

    // 5. Draw Glass Gloss Reflection Line
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final reflectionPath = Path()
      ..moveTo(w * 0.22, lipH + 6)
      ..lineTo(w * 0.22, h - cornerRadius * 0.6);

    canvas.drawPath(reflectionPath, reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) => true;
}
