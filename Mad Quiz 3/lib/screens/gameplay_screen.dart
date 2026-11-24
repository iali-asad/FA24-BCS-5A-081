import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../utils/game_colors.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_bottle_widget.dart';
import '../widgets/pouring_animation_overlay.dart';
import '../widgets/confetti_overlay.dart';

class GameplayScreen extends StatefulWidget {
  final int levelNumber;

  const GameplayScreen({super.key, required this.levelNumber});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  final Map<int, GlobalKey> _bottleKeys = {};
  bool _winHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<GameProvider>(context, listen: false);
      game.loadLevel(widget.levelNumber);
    });
  }

  GlobalKey _getKeyForIndex(int index) {
    return _bottleKeys.putIfAbsent(index, () => GlobalKey());
  }

  Rect? _getRectForIndex(int index) {
    final key = _bottleKeys[index];
    if (key == null || key.currentContext == null) return null;
    final box = key.currentContext!.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final position = box.localToGlobal(Offset.zero);
    return position & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final progress = Provider.of<ProgressProvider>(context, listen: false);
    final audio = Provider.of<AudioService>(context, listen: false);

    // Handle Victory Dialog Trigger
    if (game.isWon && !_winHandled) {
      _winHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final stars = await progress.completeLevel(
          game.levelConfig.levelNumber,
          game.moveCount,
          game.levelConfig.targetOptimalMoves,
        );
        if (mounted && context.mounted) {
          _showWinDialog(context, stars, game.moveCount, game.levelConfig.levelNumber);
        }
      });
    }

    // Reset win handled flag if level reloaded
    if (!game.isWon && _winHandled) {
      _winHandled = false;
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header Control Bar (Home, Level Info, Move Count, Pause)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeaderIconButton(
                          icon: Icons.home_rounded,
                          onTap: () {
                            audio.playClick();
                            Navigator.pop(context);
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              'LEVEL ${game.levelConfig.levelNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x40FFFFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'MOVES: ${game.moveCount}',
                                style: const TextStyle(
                                  color: GameColors.accentCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _HeaderIconButton(
                          icon: Icons.pause_rounded,
                          onTap: () {
                            game.togglePause();
                            _showPauseDialog(context, game);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Power-ups / Controls Action Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.undo_rounded,
                          label: 'UNDO',
                          isEnabled: game.canUndo,
                          onTap: () => game.undo(),
                        ),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'RESTART',
                          isEnabled: true,
                          onTap: () => game.restart(),
                        ),
                        _ActionButton(
                          icon: Icons.lightbulb_outline_rounded,
                          label: 'HINT',
                          isEnabled: true,
                          onTap: () => game.requestHint(),
                        ),
                        _ActionButton(
                          icon: Icons.add_rounded,
                          label: '+TUBE',
                          isEnabled: game.extraTubesAdded < 2,
                          onTap: () => game.addExtraTube(),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Glass Tubes Grid Display
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final total = game.tubes.length;
                      final rowCount = (total > 6) ? 2 : 1;
                      final tubesPerRow = (rowCount == 2) ? ((total + 1) ~/ 2) : total;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // First Row
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 14,
                              runSpacing: 20,
                              children: List.generate(
                                (rowCount == 2) ? tubesPerRow : total,
                                (i) => KeyedSubtree(
                                  key: _getKeyForIndex(i),
                                  child: GlassBottleWidget(
                                    bottle: game.tubes[i],
                                    isSelected: game.selectedTubeIndex == i,
                                    isHintFrom: game.currentHint?.fromIndex == i,
                                    isHintTo: game.currentHint?.toIndex == i,
                                    onTap: () => game.selectTube(i),
                                  ),
                                ),
                              ),
                            ),

                            if (rowCount == 2) ...[
                              const SizedBox(height: 32),
                              // Second Row
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 14,
                                runSpacing: 20,
                                children: List.generate(
                                  total - tubesPerRow,
                                  (i) {
                                    final index = tubesPerRow + i;
                                    return KeyedSubtree(
                                      key: _getKeyForIndex(index),
                                      child: GlassBottleWidget(
                                        bottle: game.tubes[index],
                                        isSelected: game.selectedTubeIndex == index,
                                        isHintFrom: game.currentHint?.fromIndex == index,
                                        isHintTo: game.currentHint?.toIndex == index,
                                        onTap: () => game.selectTube(index),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const Spacer(),
                ],
              ),

              // Pouring Animation Overlay
              if (game.isAnimatingPour &&
                  game.animSourceIndex != null &&
                  game.animDestIndex != null)
                Builder(
                  builder: (context) {
                    final srcRect = _getRectForIndex(game.animSourceIndex!);
                    final destRect = _getRectForIndex(game.animDestIndex!);
                    if (srcRect != null && destRect != null) {
                      return PouringAnimationOverlay(
                        sourceIndex: game.animSourceIndex!,
                        destIndex: game.animDestIndex!,
                        sourceBottle: game.tubes[game.animSourceIndex!],
                        destBottle: game.tubes[game.animDestIndex!],
                        sourceRect: srcRect,
                        destRect: destRect,
                        onComplete: () {},
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

              // Victory Confetti Particle System
              VictoryConfettiOverlay(isPlaying: game.isWon),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, GameProvider game) {
    final audio = Provider.of<AudioService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF221742),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'GAME PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.accentPurple,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text('RESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                audio.playClick();
                game.togglePause();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2E68),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('RESTART LEVEL', style: TextStyle(color: Colors.white)),
              onPressed: () {
                audio.playClick();
                game.togglePause();
                game.restart();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2E68),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              label: const Text('MAIN MENU', style: TextStyle(color: Colors.white)),
              onPressed: () {
                audio.playClick();
                game.togglePause();
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWinDialog(BuildContext context, int stars, int moves, int levelNum) {
    final audio = Provider.of<AudioService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF221742),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 64, color: GameColors.accentYellow),
              const SizedBox(height: 12),
              const Text(
                'LEVEL COMPLETED!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Earned Stars Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 38,
                    color: i < stars ? GameColors.accentYellow : Colors.white24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total Moves: $moves',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        audio.playClick();
                        Navigator.pop(ctx);
                        Provider.of<GameProvider>(context, listen: false).loadLevel(levelNum);
                      },
                      child: const Text('REPLAY', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (levelNum < 100)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.accentPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          audio.playClick();
                          Navigator.pop(ctx);
                          final nextLevel = levelNum + 1;
                          Provider.of<ProgressProvider>(context, listen: false).setCurrentLevel(nextLevel);
                          Provider.of<GameProvider>(context, listen: false).loadLevel(nextLevel);
                        },
                        child: const Text('NEXT LEVEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFF33275E) : const Color(0xFF1F183B),
            shape: BoxShape.circle,
            border: Border.all(
              color: isEnabled ? GameColors.accentCyan.withOpacity(0.5) : Colors.white10,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: GameColors.accentCyan.withOpacity(0.2),
                      blurRadius: 6,
                    )
                  ]
                : [],
          ),
          child: IconButton(
            icon: Icon(icon, color: isEnabled ? Colors.white : Colors.white24, size: 24),
            onPressed: isEnabled ? onTap : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white70 : Colors.white24,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
