import 'bottle.dart';

class LevelConfig {
  final int levelNumber;
  final int colorCount;
  final int totalTubes;
  final int capacity;
  final List<Bottle> initialTubes;
  final int targetOptimalMoves;

  LevelConfig({
    required this.levelNumber,
    required this.colorCount,
    required this.totalTubes,
    this.capacity = 4,
    required this.initialTubes,
    this.targetOptimalMoves = 15,
  });

  LevelConfig copy() {
    return LevelConfig(
      levelNumber: levelNumber,
      colorCount: colorCount,
      totalTubes: totalTubes,
      capacity: capacity,
      initialTubes: initialTubes.map((b) => b.copy()).toList(),
      targetOptimalMoves: targetOptimalMoves,
    );
  }
}
