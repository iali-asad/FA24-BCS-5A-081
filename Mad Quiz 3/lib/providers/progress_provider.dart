import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  final StorageService _storage;

  int _currentLevel = 1;
  int _unlockedLevel = 1;
  Map<int, int> _levelStars = {};
  Map<int, int> _levelBestMoves = {};
  List<String> _unlockedAchievements = [];

  ProgressProvider(this._storage) {
    _loadProgress();
  }

  int get currentLevel => _currentLevel;
  int get unlockedLevel => _unlockedLevel;
  Map<int, int> get levelStars => _levelStars;
  Map<int, int> get levelBestMoves => _levelBestMoves;
  List<String> get unlockedAchievements => _unlockedAchievements;

  int get totalStars {
    return _levelStars.values.fold(0, (sum, stars) => sum + stars);
  }

  int get completedLevelsCount {
    return _levelStars.keys.where((lvl) => (_levelStars[lvl] ?? 0) > 0).length;
  }

  double get progressPercentage {
    return (completedLevelsCount / 100.0).clamp(0.0, 1.0);
  }

  void _loadProgress() {
    _currentLevel = _storage.currentLevel;
    _unlockedLevel = _storage.unlockedLevel;
    _levelStars = _storage.levelStars;
    _levelBestMoves = _storage.levelBestMoves;
    _unlockedAchievements = _storage.unlockedAchievements;
    notifyListeners();
  }

  void setCurrentLevel(int level) {
    _currentLevel = level;
    _storage.setCurrentLevel(level);
    notifyListeners();
  }

  /// Calculates stars (1..3) based on moves taken vs target optimal moves
  int calculateStars(int moves, int optimalMoves) {
    if (moves <= optimalMoves + 2) {
      return 3;
    } else if (moves <= optimalMoves + 8) {
      return 2;
    } else {
      return 1;
    }
  }

  Future<int> completeLevel(int level, int moves, int optimalMoves) async {
    final stars = calculateStars(moves, optimalMoves);

    await _storage.setLevelStars(level, stars);
    await _storage.setLevelBestMoves(level, moves);

    // Unlock next level (up to level 100)
    if (level < 100) {
      final nextLevel = level + 1;
      await _storage.setUnlockedLevel(nextLevel);
      _unlockedLevel = _storage.unlockedLevel;
    }

    _levelStars = _storage.levelStars;
    _levelBestMoves = _storage.levelBestMoves;

    _checkAchievements();

    notifyListeners();
    return stars;
  }

  void _checkAchievements() {
    final completed = completedLevelsCount;
    final stars = totalStars;

    if (completed >= 1) _unlock('first_pour');
    if (completed >= 5) _unlock('novice_sorter');
    if (completed >= 25) _unlock('puzzle_master');
    if (completed >= 50) _unlock('halfway_there');
    if (completed >= 100) _unlock('century_champion');
    if (stars >= 50) _unlock('star_collector');

    int threeStarCount = _levelStars.values.where((s) => s == 3).length;
    if (threeStarCount >= 20) _unlock('perfectionist');
  }

  Future<void> _unlock(String id) async {
    if (!_unlockedAchievements.contains(id)) {
      await _storage.unlockAchievement(id);
      _unlockedAchievements = _storage.unlockedAchievements;
    }
  }

  Future<void> resetAll() async {
    await _storage.resetProgress();
    _loadProgress();
  }
}
