import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../utils/game_colors.dart';
import '../widgets/gradient_background.dart';
import 'level_select_screen.dart';
import 'gameplay_screen.dart';
import 'how_to_play_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final audio = Provider.of<AudioService>(context, listen: false);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative Logo Tube & Glowing Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.accentPurple.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      size: 80,
                      color: GameColors.accentCyan,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Game Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [GameColors.accentCyan, GameColors.accentPurple, GameColors.pink],
                    ).createShader(bounds),
                    child: const Text(
                      'COLOR FLOW',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Text(
                    'WATER SORT PUZZLE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // PLAY GAME Button (Primary Big Glow Action)
                  _MenuButton(
                    label: 'PLAY GAME',
                    icon: Icons.play_arrow_rounded,
                    isPrimary: true,
                    onTap: () {
                      audio.playClick();
                      final currentLevel = progress.currentLevel;
                      Provider.of<GameProvider>(context, listen: false).loadLevel(currentLevel);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameplayScreen(levelNumber: currentLevel),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // LEVEL SELECTION Button
                  _MenuButton(
                    label: 'LEVEL SELECT',
                    icon: Icons.grid_view_rounded,
                    onTap: () {
                      audio.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // HOW TO PLAY Button
                  _MenuButton(
                    label: 'HOW TO PLAY',
                    icon: Icons.help_outline_rounded,
                    onTap: () {
                      audio.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ACHIEVEMENTS Button
                  _MenuButton(
                    label: 'ACHIEVEMENTS',
                    icon: Icons.emoji_events_rounded,
                    onTap: () {
                      audio.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // SETTINGS Button
                  _MenuButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_rounded,
                    onTap: () {
                      audio.playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // EXIT Button
                  _MenuButton(
                    label: 'EXIT',
                    icon: Icons.power_settings_new_rounded,
                    isDanger: true,
                    onTap: () {
                      audio.playClick();
                      _showExitDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF221742),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Game', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to exit Color Flow?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.pink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('EXIT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDanger;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    Color btnColor;
    if (isPrimary) {
      btnColor = GameColors.accentPurple;
    } else if (isDanger) {
      btnColor = Colors.redAccent.withOpacity(0.3);
    } else {
      btnColor = const Color(0xFF2E2452);
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isPrimary ? GameColors.accentCyan : Colors.white24,
          width: isPrimary ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? GameColors.accentCyan.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: isPrimary ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isPrimary ? 18 : 16,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
