import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bottle.dart';
import '../utils/game_colors.dart';

class PouringAnimationOverlay extends StatefulWidget {
  final int sourceIndex;
  final int destIndex;
  final Bottle sourceBottle;
  final Bottle destBottle;
  final Rect sourceRect;
  final Rect destRect;
  final VoidCallback onComplete;

  const PouringAnimationOverlay({
    super.key,
    required this.sourceIndex,
    required this.destIndex,
    required this.sourceBottle,
    required this.destBottle,
    required this.sourceRect,
    required this.destRect,
    required this.onComplete,
  });

  @override
  State<PouringAnimationOverlay> createState() => _PouringAnimationOverlayState();
}

class _PouringAnimationOverlayState extends State<PouringAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final srcCenter = widget.sourceRect.center;
    final destCenter = widget.destRect.center;
    final isPouringRight = destCenter.dx >= srcCenter.dx;

    final colorIdx = widget.sourceBottle.topColor ?? 0;
    final liquidColor = GameColors.liquidColors[colorIdx % GameColors.liquidColors.length];
    final darkLiquidColor = GameColors.liquidDarkColors[colorIdx % GameColors.liquidDarkColors.length];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        // Keyframe timeline intervals
        // 0.0 -> 0.25: Lift, translate & tilt
        // 0.25 -> 0.75: Stream pouring & liquid level transfer
        // 0.75 -> 1.00: Un-tilt & return home

        final targetX = isPouringRight
            ? destCenter.dx - widget.sourceRect.width * 0.40
            : destCenter.dx + widget.sourceRect.width * 0.40;
        final targetY = destCenter.dy - widget.sourceRect.height * 0.82;

        double currentX;
        double currentY;
        double currentTilt;

        final maxTilt = isPouringRight ? (pi / 2.8) : (-pi / 2.8);

        if (t <= 0.25) {
          final progress = Curves.easeOutCubic.transform(t / 0.25);
          currentX = srcCenter.dx + (targetX - srcCenter.dx) * progress;
          currentY = srcCenter.dy + (targetY - srcCenter.dy) * progress;
          currentTilt = maxTilt * progress;
        } else if (t <= 0.75) {
          currentX = targetX;
          currentY = targetY;
          currentTilt = maxTilt;
        } else {
          final progress = Curves.easeInOutCubic.transform((t - 0.75) / 0.25);
          currentX = targetX + (srcCenter.dx - targetX) * progress;
          currentY = targetY + (srcCenter.dy - targetY) * progress;
          currentTilt = maxTilt * (1.0 - progress);
        }

        // Stream visibility & flow progress during pouring phase
        final isStreamActive = (t >= 0.20 && t <= 0.80);
        final streamProgress = isStreamActive
            ? ((t - 0.20) / 0.60).clamp(0.0, 1.0)
            : 0.0;

        // Spout origin offset calculation on tilted source bottle
        final spoutOffsetX = isPouringRight
            ? widget.sourceRect.width * 0.35
            : -widget.sourceRect.width * 0.35;
        final spoutOffsetY = -widget.sourceRect.height * 0.40;

        final spoutX = currentX + spoutOffsetX * cos(currentTilt) - spoutOffsetY * sin(currentTilt);
        final spoutY = currentY + spoutOffsetX * sin(currentTilt) + spoutOffsetY * cos(currentTilt);

        final destSpoutX = destCenter.dx;
        final destSpoutY = destCenter.dy - widget.destRect.height * 0.42;

        return Stack(
          children: [
            // Dynamic Stream Flow with Bezier Parabolic Path & Splash Ripples
            if (isStreamActive)
              CustomPaint(
                size: Size.infinite,
                painter: _RealisticStreamPainter(
                  spoutPoint: Offset(spoutX, spoutY),
                  targetPoint: Offset(destSpoutX, destSpoutY),
                  color: liquidColor,
                  darkColor: darkLiquidColor,
                  flowProgress: streamProgress,
                ),
              ),

            // Source Bottle (Tilting Overlay)
            Positioned(
              left: currentX - widget.sourceRect.width / 2,
              top: currentY - widget.sourceRect.height / 2,
              child: Transform.rotate(
                angle: currentTilt,
                child: SizedBox(
                  width: widget.sourceRect.width,
                  height: widget.sourceRect.height,
                  child: CustomPaint(
                    painter: _PouringSourceBottlePainter(
                      bottle: widget.sourceBottle,
                      pourProgress: streamProgress,
                      liquidColor: liquidColor,
                      darkColor: darkLiquidColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RealisticStreamPainter extends CustomPainter {
  final Offset spoutPoint;
  final Offset targetPoint;
  final Color color;
  final Color darkColor;
  final double flowProgress;

  _RealisticStreamPainter({
    required this.spoutPoint,
    required this.targetPoint,
    required this.color,
    required this.darkColor,
    required this.flowProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Parabolic control point for natural water arc
    final controlX = (spoutPoint.dx + targetPoint.dx) / 2;
    final controlY = min(spoutPoint.dy, targetPoint.dy) + 20.0;

    final path = Path()
      ..moveTo(spoutPoint.dx, spoutPoint.dy)
      ..quadraticBezierTo(controlX, controlY, targetPoint.dx, targetPoint.dy);

    // Stream width animation (builds up, holds, tapers down)
    double streamWidth;
    if (flowProgress < 0.15) {
      streamWidth = 2.0 + (flowProgress / 0.15) * 6.0;
    } else if (flowProgress > 0.85) {
      streamWidth = 8.0 * ((1.0 - flowProgress) / 0.15);
    } else {
      streamWidth = 8.0;
    }

    if (streamWidth <= 0.5) return;

    // Outer Glow / Ambient Liquid Shader
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = streamWidth + 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(path, glowPaint);

    // Core Liquid Stream Line
    final streamPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, darkColor],
      ).createShader(Rect.fromPoints(spoutPoint, targetPoint))
      ..style = PaintingStyle.stroke
      ..strokeWidth = streamWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, streamPaint);

    // Liquid Surface Splash Ripples at Target Mouth
    final splashRadius = 4.0 + sin(flowProgress * pi * 8) * 3.0;
    final splashPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(targetPoint, splashRadius, splashPaint);
  }

  @override
  bool shouldRepaint(covariant _RealisticStreamPainter oldDelegate) => true;
}

class _PouringSourceBottlePainter extends CustomPainter {
  final Bottle bottle;
  final double pourProgress;
  final Color liquidColor;
  final Color darkColor;

  _PouringSourceBottlePainter({
    required this.bottle,
    required this.pourProgress,
    required this.liquidColor,
    required this.darkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cornerRadius = w * 0.42;
    final lipH = h * 0.04;
    final lipOverhang = w * 0.10;

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

    // Glass Fill
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..style = PaintingStyle.fill,
    );

    // Remaining Liquid Blocks inside bottle
    canvas.save();
    canvas.clipPath(innerPath);

    final playableHeight = h - lipH - 6;
    final segmentHeight = playableHeight / bottle.capacity;

    for (int i = 0; i < bottle.colors.length; i++) {
      final isTop = (i == bottle.colors.length - 1);
      final colorIdx = bottle.colors[i];
      final mainC = GameColors.liquidColors[colorIdx % GameColors.liquidColors.length];
      final darkC = GameColors.liquidDarkColors[colorIdx % GameColors.liquidDarkColors.length];

      double topY = h - (i + 1) * segmentHeight;
      double bottomY = h - i * segmentHeight;

      // If this is the top liquid segment being poured, shrink its height dynamically!
      if (isTop) {
        final currentH = segmentHeight * (1.0 - pourProgress);
        topY = bottomY - currentH;
      }

      if (bottomY > topY) {
        final rect = Rect.fromLTRB(0, topY, w, bottomY);
        final paint = Paint()
          ..shader = LinearGradient(
            colors: [mainC, darkC],
          ).createShader(rect);
        canvas.drawRect(rect, paint);
      }
    }
    canvas.restore();

    // Glass Tube Border Glow
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = GameColors.accentCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Reflection shine
    canvas.drawLine(
      Offset(w * 0.22, lipH + 4),
      Offset(w * 0.22, h - cornerRadius * 0.5),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _PouringSourceBottlePainter oldDelegate) => true;
}
