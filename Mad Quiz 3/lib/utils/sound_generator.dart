import 'dart:math' as math;
import 'dart:typed_data';

class SoundGenerator {
  /// Generates a WAV sound byte array for a given waveform function.
  static Uint8List createWavBytes({
    required double durationSeconds,
    required double sampleRate,
    required double Function(double t) waveFunc,
  }) {
    final numSamples = (durationSeconds * sampleRate).toInt();
    final dataSize = numSamples * 2; // 16-bit mono
    final fileSize = 44 + dataSize;

    final bytes = ByteData(fileSize);

    // RIFF header
    bytes.setUint8(0, 0x52); // 'R'
    bytes.setUint8(1, 0x49); // 'I'
    bytes.setUint8(2, 0x46); // 'F'
    bytes.setUint8(3, 0x46); // 'F'
    bytes.setUint32(4, fileSize - 8, Endian.little);
    bytes.setUint8(8, 0x57);  // 'W'
    bytes.setUint8(9, 0x41);  // 'A'
    bytes.setUint8(10, 0x56); // 'V'
    bytes.setUint8(11, 0x45); // 'E'

    // fmt chunk
    bytes.setUint8(12, 0x66); // 'f'
    bytes.setUint8(13, 0x6D); // 'm'
    bytes.setUint8(14, 0x74); // 't'
    bytes.setUint8(15, 0x20); // ' '
    bytes.setUint32(16, 16, Endian.little); // Chunk size 16
    bytes.setUint16(20, 1, Endian.little);  // PCM format
    bytes.setUint16(22, 1, Endian.little);  // 1 channel (mono)
    bytes.setUint32(24, sampleRate.toInt(), Endian.little); // Sample rate
    bytes.setUint32(28, (sampleRate * 2).toInt(), Endian.little); // Byte rate
    bytes.setUint16(32, 2, Endian.little);  // Block align (16-bit mono)
    bytes.setUint16(34, 16, Endian.little); // Bits per sample

    // data chunk
    bytes.setUint8(36, 0x64); // 'd'
    bytes.setUint8(37, 0x61); // 'a'
    bytes.setUint8(38, 0x74); // 't'
    bytes.setUint8(39, 0x61); // 'a'
    bytes.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final sampleVal = (waveFunc(t) * 32767).clamp(-32768, 32767).toInt();
      bytes.setInt16(offset, sampleVal, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Button Click Sound (Short high pop)
  static Uint8List generateClickWav() {
    return createWavBytes(
      durationSeconds: 0.08,
      sampleRate: 22050,
      waveFunc: (t) {
        final freq = 800 - (t * 4000);
        final envelope = math.exp(-t * 45);
        return math.sin(2 * math.pi * freq * t) * envelope;
      },
    );
  }

  /// Bottle Select Sound (Soft pop up)
  static Uint8List generateSelectWav() {
    return createWavBytes(
      durationSeconds: 0.12,
      sampleRate: 22050,
      waveFunc: (t) {
        final freq = 440 + (t * 1200);
        final envelope = math.exp(-t * 25);
        return math.sin(2 * math.pi * freq * t) * envelope * 0.8;
      },
    );
  }

  /// Water Pouring Sound (Bubble stream sound effect)
  static Uint8List generatePourWav() {
    final rand = math.Random(42);
    return createWavBytes(
      durationSeconds: 0.45,
      sampleRate: 22050,
      waveFunc: (t) {
        final baseFreq = 520 + math.sin(t * 50) * 120;
        final noise = (rand.nextDouble() - 0.5) * 0.25;
        final bubble = math.sin(2 * math.pi * baseFreq * t);
        final envelope = (t < 0.05) ? (t / 0.05) : math.exp(-(t - 0.05) * 4);
        return (bubble + noise) * envelope * 0.6;
      },
    );
  }

  /// Invalid Move Error Sound (Low buzz)
  static Uint8List generateErrorWav() {
    return createWavBytes(
      durationSeconds: 0.20,
      sampleRate: 22050,
      waveFunc: (t) {
        final freq = 150 + math.sin(t * 100) * 30;
        final envelope = math.exp(-t * 12);
        final squareWave = (math.sin(2 * math.pi * freq * t) > 0) ? 0.6 : -0.6;
        return squareWave * envelope;
      },
    );
  }

  /// Level Complete Win Fanfare Sound
  static Uint8List generateWinWav() {
    return createWavBytes(
      durationSeconds: 0.65,
      sampleRate: 22050,
      waveFunc: (t) {
        // Arpeggio C5 -> E5 -> G5 -> C6
        double freq = 523.25; // C5
        if (t > 0.12) freq = 659.25; // E5
        if (t > 0.24) freq = 783.99; // G5
        if (t > 0.36) freq = 1046.50; // C6

        final envelope = math.exp(-(t % 0.12) * 15);
        final harmonic = math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(4 * math.pi * freq * t);
        return harmonic * envelope * 0.7;
      },
    );
  }
}
