class Bottle {
  final int capacity;
  final List<int> colors; // List of color indices (0..7), 0 is bottom, top is last element

  Bottle({
    this.capacity = 4,
    List<int>? colors,
  }) : colors = colors != null ? List<int>.from(colors) : <int>[];

  bool get isEmpty => colors.isEmpty;
  bool get isFull => colors.length >= capacity;
  int get spaceLeft => capacity - colors.length;

  int? get topColor => colors.isEmpty ? null : colors.last;

  /// Returns how many contiguous matching colors are at the top of this tube
  int get topColorCount {
    if (isEmpty) return 0;
    final top = colors.last;
    int count = 0;
    for (int i = colors.length - 1; i >= 0; i--) {
      if (colors[i] == top) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Check if the bottle is completely solved (filled to capacity with identical color)
  bool get isSolved {
    if (colors.length != capacity) return false;
    final first = colors.first;
    return colors.every((c) => c == first);
  }

  /// Check if pouring from this bottle into [dest] is valid
  bool canPourInto(Bottle dest) {
    if (isEmpty) return false;
    if (dest.isFull) return false;
    if (dest.isEmpty) return true;
    return topColor == dest.topColor;
  }

  /// Calculates how many color segments can be poured from this bottle into [dest]
  int pourableAmount(Bottle dest) {
    if (!canPourInto(dest)) return 0;
    final amountInSource = topColorCount;
    final spaceInDest = dest.spaceLeft;
    return amountInSource < spaceInDest ? amountInSource : spaceInDest;
  }

  /// Creates a deep copy of this Bottle
  Bottle copy() {
    return Bottle(
      capacity: capacity,
      colors: List<int>.from(colors),
    );
  }

  Map<String, dynamic> toJson() => {
        'capacity': capacity,
        'colors': colors,
      };

  factory Bottle.fromJson(Map<String, dynamic> json) => Bottle(
        capacity: json['capacity'] as int? ?? 4,
        colors: (json['colors'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      );
}
