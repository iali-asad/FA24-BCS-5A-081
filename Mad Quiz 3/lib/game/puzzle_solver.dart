import '../models/bottle.dart';

class HintMove {
  final int fromIndex;
  final int toIndex;
  final int score;

  HintMove({
    required this.fromIndex,
    required this.toIndex,
    required this.score,
  });
}

class PuzzleSolver {
  /// Finds the best valid move hint for the current tubes configuration
  static HintMove? findBestHint(List<Bottle> tubes) {
    final moves = <HintMove>[];

    for (int i = 0; i < tubes.length; i++) {
      final src = tubes[i];
      if (src.isEmpty || src.isSolved) continue;

      for (int j = 0; j < tubes.length; j++) {
        if (i == j) continue;
        final dest = tubes[j];

        if (!src.canPourInto(dest)) continue;

        int score = 0;

        // 1. Higher score if pouring completes a destination tube to solved state
        final amount = src.pourableAmount(dest);
        if (dest.colors.length + amount == dest.capacity &&
            (dest.isEmpty || dest.topColor == src.topColor)) {
          score += 100;
        }

        // 2. High score if pouring clears out a source tube or unites matching top colors
        if (dest.topColor == src.topColor) {
          score += 50;
        }

        // 3. Medium score if pouring clears out a mixed source tube onto identical color
        if (src.topColorCount == src.colors.length) {
          // Source is monochromatic - only pour to empty if necessary
          if (dest.isEmpty) {
            score += 10;
          } else {
            score += 40;
          }
        } else {
          // Source has multiple colors - pouring top is good
          score += 30;
        }

        moves.add(HintMove(fromIndex: i, toIndex: j, score: score));
      }
    }

    if (moves.isEmpty) return null;

    moves.sort((a, b) => b.score.compareTo(a.score));
    return moves.first;
  }
}
