import 'package:flutter/services.dart';

class AudioService {
  static const MethodChannel _platformChannel =
      MethodChannel('com.colorflow.watersort/audio');

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  Future<void> init() async {}

  void _playSound(String name) {
    if (!sfxEnabled) return;
    try {
      _platformChannel.invokeMethod('playSound', name);
    } catch (_) {
      // Fallback to system sound
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playClick() {
    _playSound('click');
    vibrateLight();
  }

  void playSelect() {
    _playSound('select');
    vibrateLight();
  }

  void playPour() {
    _playSound('pour');
    vibrateLight();
  }

  void playError() {
    _playSound('error');
    vibrateMedium();
  }

  void playWin() {
    _playSound('win');
    vibrateHeavy();
  }

  void vibrateLight() {
    if (!vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  void vibrateMedium() {
    if (!vibrationEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void vibrateHeavy() {
    if (!vibrationEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void dispose() {}
}
