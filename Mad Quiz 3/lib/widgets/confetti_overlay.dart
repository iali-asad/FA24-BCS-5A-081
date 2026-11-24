import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../utils/game_colors.dart';

class VictoryConfettiOverlay extends StatefulWidget {
  final bool isPlaying;

  const VictoryConfettiOverlay({super.key, required this.isPlaying});

  @override
  State<VictoryConfettiOverlay> createState() => _VictoryConfettiOverlayState();
}

class _VictoryConfettiOverlayState extends State<VictoryConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.isPlaying) {
      _controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant VictoryConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          GameColors.red,
          GameColors.blue,
          GameColors.green,
          GameColors.yellow,
          GameColors.purple,
          GameColors.pink,
          GameColors.cyan,
        ],
        numberOfParticles: 35,
        gravity: 0.15,
      ),
    );
  }
}
