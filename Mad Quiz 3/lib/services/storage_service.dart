import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyCurrentLevel = 'current_level';
  static const String keyUnlockedLevel = 'unlocked_level';
  static const String keyLevelStars = 'level_stars';
  static const String keyLevelBestMoves = 'level_best_moves';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keySfxEnabled = 'sfx_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyUnlockedAchievements = 'unlocked_achievements';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get currentLevel => _prefs.getInt(keyCurrentLevel) ?? 1;
  Future<void> setCurrentLevel(int level) async {
    await _prefs.setInt(keyCurrentLevel, level);
  }

  int get unlockedLevel => _prefs.getInt(keyUnlockedLevel) ?? 1;
  Future<void> setUnlockedLevel(int level) async {
    final currentUnlocked = unlockedLevel;
    if (level > currentUnlocked) {
      await _prefs.setInt(keyUnlockedLevel, level);
    }
  }

  Map<int, int> get levelStars {
    final raw = _prefs.getString(keyLevelStars);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> setLevelStars(int level, int stars) async {
    final starsMap = levelStars;
    final existing = starsMap[level] ?? 0;
    if (stars > existing) {
      starsMap[level] = stars;
      final encoded = jsonEncode(starsMap.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs.setString(keyLevelStars, encoded);
    }
  }

  Map<int, int> get levelBestMoves {
    final raw = _prefs.getString(keyLevelBestMoves);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> setLevelBestMoves(int level, int moves) async {
    final movesMap = levelBestMoves;
    final existing = movesMap[level];
    if (existing == null || moves < existing) {
      movesMap[level] = moves;
      final encoded = jsonEncode(movesMap.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs.setString(keyLevelBestMoves, encoded);
    }
  }

  bool get musicEnabled => _prefs.getBool(keyMusicEnabled) ?? true;
  Future<void> setMusicEnabled(bool value) async {
    await _prefs.setBool(keyMusicEnabled, value);
  }

  bool get sfxEnabled => _prefs.getBool(keySfxEnabled) ?? true;
  Future<void> setSfxEnabled(bool value) async {
    await _prefs.setBool(keySfxEnabled, value);
  }

  bool get vibrationEnabled => _prefs.getBool(keyVibrationEnabled) ?? true;
  Future<void> setVibrationEnabled(bool value) async {
    await _prefs.setBool(keyVibrationEnabled, value);
  }

  List<String> get unlockedAchievements =>
      _prefs.getStringList(keyUnlockedAchievements) ?? [];

  Future<void> unlockAchievement(String id) async {
    final list = unlockedAchievements;
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList(keyUnlockedAchievements, list);
    }
  }

  Future<void> resetProgress() async {
    await _prefs.clear();
  }
}
