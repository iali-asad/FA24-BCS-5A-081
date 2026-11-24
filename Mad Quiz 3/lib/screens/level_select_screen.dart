import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../utils/game_colors.dart';
import '../widgets/gradient_background.dart';
import 'gameplay_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final audio = Provider.of<AudioService>(context, listen: false);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () {
                        audio.playClick();
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'LEVEL SELECT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    // Total stars indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.cardGradient.colors.first,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameColors.accentYellow.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: GameColors.accentYellow, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.totalStars}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Overall Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completed: ${progress.completedLevelsCount} / 100',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '${(progress.progressPercentage * 100).toInt()}%',
                          style: const TextStyle(
                            color: GameColors.accentCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress.progressPercentage,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(GameColors.accentCyan),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 100 Levels Grid View
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    final levelNum = index + 1;
                    final isUnlocked = levelNum <= progress.unlockedLevel;
                    final stars = progress.levelStars[levelNum] ?? 0;

                    return _LevelGridTile(
                      levelNumber: levelNum,
                      isUnlocked: isUnlocked,
                      stars: stars,
                      onTap: () {
                        if (isUnlocked) {
                          audio.playClick();
                          progress.setCurrentLevel(levelNum);
                          Provider.of<GameProvider>(context, listen: false).loadLevel(levelNum);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameplayScreen(levelNumber: levelNum),
                            ),
                          );
                        } else {
                          audio.playError();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelGridTile extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onTap;

  const _LevelGridTile({
    required this.levelNumber,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnlocked ? const Color(0xFF2F2458) : const Color(0xFF1B1536),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? GameColors.accentPurple.withOpacity(0.7) : Colors.white10,
            width: 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: GameColors.accentPurple.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock_rounded, color: Colors.white38, size: 24)
            else ...[
              Text(
                '$levelNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: i < stars ? GameColors.accentYellow : Colors.white24,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
