import 'package:flutter/material.dart';

class GameColors {
  // 8 Vibrant liquid colors
  static const Color red = Color(0xFFFF3B30);
  static const Color blue = Color(0xFF007AFF);
  static const Color green = Color(0xFF34C759);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color purple = Color(0xFFAF52DE);
  static const Color orange = Color(0xFFFF9500);
  static const Color pink = Color(0xFFFF2D55);
  static const Color cyan = Color(0xFF5AC8FA);

  // List of liquid colors indexed 0 to 7
  static const List<Color> liquidColors = [
    red,
    blue,
    green,
    yellow,
    purple,
    orange,
    pink,
    cyan,
  ];

  // Liquid color names for debugging/hints
  static const List<String> liquidNames = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Purple',
    'Orange',
    'Pink',
    'Cyan',
  ];

  // Secondary gradient colors for liquid depth
  static const List<Color> liquidDarkColors = [
    Color(0xFFC70000), // Red dark
    Color(0xFF0040DD), // Blue dark
    Color(0xFF1B8A38), // Green dark
    Color(0xFFD49E00), // Yellow dark
    Color(0xFF751AAA), // Purple dark
    Color(0xFFC85A00), // Orange dark
    Color(0xFFC70030), // Pink dark
    Color(0xFF008BBF), // Cyan dark
  ];

  // UI Background Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E1E38),
      Color(0xFF2A1B4E),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D2350),
      Color(0xFF1F173B),
    ],
  );

  // Accent Colors
  static const Color accentPurple = Color(0xFF9D4EDD);
  static const Color accentCyan = Color(0xFF00F5D4);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color glassBorder = Color(0x99FFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  // Glass tube colors
  static const Color bottleGlassBorder = Color(0xB3FFFFFF);
  static const Color bottleSelectedGlow = Color(0xFF00F5D4);
}
