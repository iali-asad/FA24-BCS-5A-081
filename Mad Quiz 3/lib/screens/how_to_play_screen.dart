import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'package:provider/provider.dart';
import '../utils/game_colors.dart';
import '../widgets/gradient_background.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioService>(context, listen: false);

    final steps = [
      _TutorialStep(
        stepNumber: 1,
        title: 'Select Source Bottle',
        description: 'Tap any non-empty test tube to pick it up.',
        icon: Icons.touch_app_rounded,
        color: GameColors.accentCyan,
      ),
      _TutorialStep(
        stepNumber: 2,
        title: 'Select Destination',
        description: 'Tap another tube to pour liquid into it.',
        icon: Icons.water_drop_rounded,
        color: GameColors.accentPurple,
      ),
      _TutorialStep(
        stepNumber: 3,
        title: 'Match Top Colors',
        description: 'Liquid can only be poured if top colors match or target is empty.',
        icon: Icons.palette_rounded,
        color: GameColors.accentYellow,
      ),
      _TutorialStep(
        stepNumber: 4,
        title: 'Use Helper Tubes',
        description: 'Empty bottles act as temporary storage to rearrange colors.',
        icon: Icons.local_drink_rounded,
        color: GameColors.green,
      ),
      _TutorialStep(
        stepNumber: 5,
        title: 'Sort Entire Tube',
        description: 'Sort every color into its own tube to solve the puzzle!',
        icon: Icons.emoji_events_rounded,
        color: GameColors.pink,
      ),
    ];

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
                        'HOW TO PLAY',
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

              // Steps List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  itemCount: steps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2452),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: step.color.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: step.color.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: step.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(step.icon, color: step.color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STEP ${step.stepNumber}: ${step.title}',
                                  style: TextStyle(
                                    color: step.color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
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

class _TutorialStep {
  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
