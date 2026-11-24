import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/achievement.dart';
import '../services/audio_service.dart';
import '../utils/game_colors.dart';
import '../widgets/gradient_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final audio = Provider.of<AudioService>(context, listen: false);
    final achievements = Achievement.allAchievements;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                        'ACHIEVEMENTS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Stats Cards Summary Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Completed',
                        value: '${progress.completedLevelsCount} / 100',
                        icon: Icons.check_circle_rounded,
                        color: GameColors.accentCyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Stars',
                        value: '${progress.totalStars}',
                        icon: Icons.star_rounded,
                        color: GameColors.accentYellow,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Badges Grid
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  itemCount: achievements.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = achievements[index];
                    final isUnlocked = progress.unlockedAchievements.contains(item.id);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFF2E2452) : const Color(0xFF1B1536),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUnlocked ? GameColors.accentPurple : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? GameColors.accentPurple.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: isUnlocked ? GameColors.accentYellow : Colors.white24,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isUnlocked ? Colors.white : Colors.white38,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: isUnlocked ? Colors.white70 : Colors.white24,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isUnlocked
                                ? Icons.verified_rounded
                                : Icons.lock_outline_rounded,
                            color: isUnlocked ? GameColors.accentCyan : Colors.white24,
                          ),
                        ],
                      ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B204C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
