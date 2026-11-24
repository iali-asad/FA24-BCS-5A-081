import 'dart:math';
import '../models/bottle.dart';
import '../models/level.dart';

class PuzzleGenerator {
  /// Generates a level configuration for [levelNumber] (1..100)
  static LevelConfig generateLevel(int levelNumber) {
    int colorCount;
    int emptyTubes = 2;

    if (levelNumber <= 5) {
      colorCount = 2; // Very easy intro
    } else if (levelNumber <= 10) {
      colorCount = 3; // Easy
    } else if (levelNumber <= 25) {
      colorCount = 4; // Medium
    } else if (levelNumber <= 50) {
      colorCount = 5; // Hard
    } else if (levelNumber <= 75) {
      colorCount = 6; // Very Hard
    } else if (levelNumber <= 90) {
      colorCount = 7; // Expert
    } else {
      colorCount = 8; // Master
    }

    final totalTubes = colorCount + emptyTubes;

    // Create solved state
    final tubes = List<Bottle>.generate(
      totalTubes,
      (i) => (i < colorCount)
          ? Bottle(capacity: 4, colors: List.filled(4, i))
          : Bottle(capacity: 4, colors: []),
    );

    // Scramble backward from solved state with deterministic seed
    final rng = Random(levelNumber * 7919 + 101);
    final scrambleSteps = 40 + (levelNumber * 2);

    int prevSource = -1;
    int prevDest = -1;

    for (int step = 0; step < scrambleSteps; step++) {
      // Find all valid reverse pours (or valid standard pours between tubes)
      final candidates = <Map<String, int>>[];

      for (int i = 0; i < totalTubes; i++) {
        for (int j = 0; j < totalTubes; j++) {
          if (i == j) continue;
          if (i == prevDest && j == prevSource) continue; // Avoid instant undo flip

          final src = tubes[i];
          final dest = tubes[j];

          if (src.isEmpty) continue;
          if (dest.isFull) continue;

          // In backward shuffle, we can transfer 1 block from top of src to dest if dest is empty or top matches/differs
          // To ensure thorough scramble, we transfer top liquid block
          candidates.add({'src': i, 'dest': j});
        }
      }

      if (candidates.isEmpty) break;

      final choice = candidates[rng.nextInt(candidates.length)];
      final s = choice['src']!;
      final d = choice['dest']!;

      // Transfer top color
      final color = tubes[s].colors.removeLast();
      tubes[d].colors.add(color);

      prevSource = s;
      prevDest = d;
    }

    // Ensure no tube starts already solved or empty (except the 2 designated empty tubes)
    // If any color tube is pure, scramble a bit more
    bool needsAdjustment = true;
    int safetyCounter = 0;
    while (needsAdjustment && safetyCounter < 20) {
      safetyCounter++;
      int solvedCount = 0;
      for (final b in tubes) {
        if (b.isSolved) solvedCount++;
      }
      if (solvedCount == 0) {
        needsAdjustment = false;
      } else {
        // Shuffle one block
        for (int i = 0; i < totalTubes; i++) {
          for (int j = 0; j < totalTubes; j++) {
            if (i != j && !tubes[i].isEmpty && !tubes[j].isFull) {
              final c = tubes[i].colors.removeLast();
              tubes[j].colors.add(c);
              break;
            }
          }
        }
      }
    }

    return LevelConfig(
      levelNumber: levelNumber,
      colorCount: colorCount,
      totalTubes: totalTubes,
      initialTubes: tubes,
      targetOptimalMoves: colorCount * 4 + (levelNumber ~/ 5),
    );
  }
}
