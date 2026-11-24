import 'bottle.dart';

class MoveSnapshot {
  final int fromIndex;
  final int toIndex;
  final int count;
  final List<Bottle> previousTubesState;
  final int moveCount;

  MoveSnapshot({
    required this.fromIndex,
    required this.toIndex,
    required this.count,
    required this.previousTubesState,
    required this.moveCount,
  });
}
