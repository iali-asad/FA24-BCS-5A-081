import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int requiredProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredProgress,
  });

  static List<Achievement> get allAchievements => [
        Achievement(
          id: 'first_pour',
          title: 'First Flow',
          description: 'Complete level 1',
          icon: Icons.water_drop_rounded,
          requiredProgress: 1,
        ),
        Achievement(
          id: 'novice_sorter',
          title: 'Color Novice',
          description: 'Complete 5 levels',
          icon: Icons.star_half_rounded,
          requiredProgress: 5,
        ),
        Achievement(
          id: 'puzzle_master',
          title: 'Puzzle Master',
          description: 'Complete 25 levels',
          icon: Icons.psychology_rounded,
          requiredProgress: 25,
        ),
        Achievement(
          id: 'star_collector',
          title: 'Star Collector',
          description: 'Earn 50 total stars',
          icon: Icons.star_rounded,
          requiredProgress: 50,
        ),
        Achievement(
          id: 'halfway_there',
          title: 'Halfway Hero',
          description: 'Complete 50 levels',
          icon: Icons.emoji_events_rounded,
          requiredProgress: 50,
        ),
        Achievement(
          id: 'perfectionist',
          title: 'Perfectionist',
          description: 'Earn 3 stars on 20 levels',
          icon: Icons.workspace_premium_rounded,
          requiredProgress: 20,
        ),
        Achievement(
          id: 'century_champion',
          title: 'Flow Legend',
          description: 'Complete all 100 levels',
          icon: Icons.military_tech_rounded,
          requiredProgress: 100,
        ),
      ];
}
