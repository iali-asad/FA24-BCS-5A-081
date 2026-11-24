import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  final AudioService _audio;

  late bool _musicEnabled;
  late bool _sfxEnabled;
  late bool _vibrationEnabled;

  SettingsProvider(this._storage, this._audio) {
    _musicEnabled = _storage.musicEnabled;
    _sfxEnabled = _storage.sfxEnabled;
    _vibrationEnabled = _storage.vibrationEnabled;

    _syncAudio();
  }

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void toggleMusic(bool val) {
    _musicEnabled = val;
    _storage.setMusicEnabled(val);
    _syncAudio();
    notifyListeners();
  }

  void toggleSfx(bool val) {
    _sfxEnabled = val;
    _storage.setSfxEnabled(val);
    _syncAudio();
    notifyListeners();
  }

  void toggleVibration(bool val) {
    _vibrationEnabled = val;
    _storage.setVibrationEnabled(val);
    _syncAudio();
    notifyListeners();
  }

  void _syncAudio() {
    _audio.musicEnabled = _musicEnabled;
    _audio.sfxEnabled = _sfxEnabled;
    _audio.vibrationEnabled = _vibrationEnabled;
  }
}
