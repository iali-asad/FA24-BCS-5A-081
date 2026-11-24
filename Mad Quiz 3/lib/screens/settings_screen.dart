import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../utils/game_colors.dart';
import '../widgets/gradient_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final progress = Provider.of<ProgressProvider>(context, listen: false);
    final audio = Provider.of<AudioService>(context, listen: false);

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
                        'SETTINGS',
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

              const SizedBox(height: 24),

              // Settings Items List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2452),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _SettingToggleTile(
                        title: 'Background Music',
                        subtitle: 'Enable ambient music',
                        icon: Icons.music_note_rounded,
                        value: settings.musicEnabled,
                        onChanged: (val) {
                          audio.playClick();
                          settings.toggleMusic(val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      _SettingToggleTile(
                        title: 'Sound Effects',
                        subtitle: 'Pouring, selecting, and UI sounds',
                        icon: Icons.volume_up_rounded,
                        value: settings.sfxEnabled,
                        onChanged: (val) {
                          audio.playClick();
                          settings.toggleSfx(val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      _SettingToggleTile(
                        title: 'Vibration Haptics',
                        subtitle: 'Haptic feedback on taps',
                        icon: Icons.vibration_rounded,
                        value: settings.vibrationEnabled,
                        onChanged: (val) {
                          audio.playClick();
                          settings.toggleVibration(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Reset Progress Action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 28),
                    title: const Text(
                      'Reset All Progress',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Clear all level unlocks, stars, and achievements',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    onTap: () {
                      audio.playClick();
                      _showResetConfirmation(context, progress);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, ProgressProvider progress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF221742),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This action cannot be undone. All completed levels, stars, and unlocked achievements will be wiped.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await progress.resetAll();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All progress has been reset.')),
                );
              }
            },
            child: const Text('RESET', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SettingToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      secondary: Icon(icon, color: GameColors.accentCyan, size: 26),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      activeColor: GameColors.accentPurple,
      activeTrackColor: GameColors.accentCyan,
      value: value,
      onChanged: onChanged,
    );
  }
}
