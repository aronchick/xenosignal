import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

/// Geiger counter audio service.
///
/// Produces clicking sounds with frequency proportional to signal strength.
/// Mimics the classic motion tracker from Aliens.
///
/// Click frequency ranges:
/// - Poor signal (0-30%): 0.5-1 clicks/sec (1000-2000ms interval)
/// - Fair signal (30-60%): 1-4 clicks/sec (250-1000ms interval)
/// - Good signal (60-80%): 4-8 clicks/sec (125-250ms interval)
/// - Excellent signal (80-100%): 8-12 clicks/sec (83-125ms interval)
class GeigerAudioService {
  GeigerAudioService();

  AudioPlayer? _player;
  Timer? _clickTimer;
  bool _isEnabled = false;
  double _volume = 0.7;
  int _currentQuality = 0;

  /// Whether the audio service is currently active.
  bool get isEnabled => _isEnabled;

  /// Current volume level (0.0-1.0).
  double get volume => _volume;

  /// Initializes the audio player with a synthetic click sound.
  Future<void> initialize() async {
    _player = AudioPlayer();

    // Generate synthetic click sound (short burst)
    final clickData = _generateClickSound();
    final source = _SyntheticAudioSource(clickData);

    await _player!.setAudioSource(source);
    await _player!.setVolume(_volume);
  }

  /// Starts the Geiger counter with the given signal quality.
  ///
  /// [qualityScore] should be 0-100.
  /// Does nothing if [initialize] hasn't been called.
  void start(int qualityScore) {
    if (_player == null) {
      // Player not initialized - cannot start
      return;
    }

    _isEnabled = true;
    _currentQuality = qualityScore.clamp(0, 100);
    _scheduleNextClick();
  }

  /// Updates the signal quality, adjusting click frequency.
  void updateSignalQuality(int qualityScore) {
    if (!_isEnabled) return;

    _currentQuality = qualityScore.clamp(0, 100);
    // Timer will adjust on next tick
  }

  /// Stops the Geiger counter audio.
  void stop() {
    _isEnabled = false;
    _clickTimer?.cancel();
    _clickTimer = null;
  }

  /// Sets the audio volume.
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player?.setVolume(_volume);
  }

  /// Releases audio resources.
  Future<void> dispose() async {
    stop();
    await _player?.dispose();
    _player = null;
  }

  void _scheduleNextClick() {
    if (!_isEnabled || _player == null) return;

    final interval = _calculateInterval(_currentQuality);

    _clickTimer?.cancel();
    _clickTimer = Timer(Duration(milliseconds: interval), () async {
      if (!_isEnabled) return;

      // Play click
      await _player!.seek(Duration.zero);
      await _player!.play();

      // Schedule next
      _scheduleNextClick();
    });
  }

  /// Calculates click interval in milliseconds based on signal quality.
  int _calculateInterval(int quality) {
    // Map quality (0-100) to interval (2000ms-83ms)
    // Using exponential curve for more dramatic effect at high signal
    const minInterval = 83; // 12 clicks/sec at 100%
    const maxInterval = 2000; // 0.5 clicks/sec at 0%

    // Exponential interpolation: interval = max * (min/max)^(quality/100)
    final ratio = quality / 100.0;
    final interval = maxInterval * math.pow(minInterval / maxInterval, ratio);

    return interval.round().clamp(minInterval, maxInterval);
  }

  /// Generates a synthetic click sound as WAV data.
  ///
  /// Creates a short (~30ms) sharp click with quick attack and decay.
  Uint8List _generateClickSound() {
    const sampleRate = 44100;
    const durationMs = 30;
    const numSamples = (sampleRate * durationMs) ~/ 1000;
    const frequency = 2500.0; // 2.5kHz primary frequency

    // Create samples
    final samples = Float32List(numSamples);
    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = _clickEnvelope(i / numSamples);

      // Mix fundamental with harmonics for crispy click
      final wave = math.sin(2 * math.pi * frequency * t) +
          0.5 * math.sin(2 * math.pi * frequency * 2 * t) +
          0.25 * math.sin(2 * math.pi * frequency * 3 * t);

      samples[i] = (wave * envelope * 0.3).clamp(-1.0, 1.0);
    }

    return _encodeWav(samples, sampleRate);
  }

  /// Attack-decay envelope for click sound.
  double _clickEnvelope(double position) {
    const attackEnd = 0.1; // First 10% is attack
    const decayStart = 0.1;

    if (position < attackEnd) {
      // Quick attack
      return position / attackEnd;
    } else {
      // Exponential decay
      final decayPosition = (position - decayStart) / (1 - decayStart);
      return math.exp(-5 * decayPosition);
    }
  }

  /// Encodes samples as a WAV file.
  Uint8List _encodeWav(Float32List samples, int sampleRate) {
    const channels = 1;
    const bitsPerSample = 16;
    final dataSize = samples.length * (bitsPerSample ~/ 8);
    final fileSize = 44 + dataSize;

    final buffer = ByteData(fileSize);
    var offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // R
    buffer.setUint8(offset++, 0x49); // I
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint32(offset, fileSize - 8, Endian.little);
    offset += 4;
    buffer.setUint8(offset++, 0x57); // W
    buffer.setUint8(offset++, 0x41); // A
    buffer.setUint8(offset++, 0x56); // V
    buffer.setUint8(offset++, 0x45); // E

    // fmt chunk
    buffer.setUint8(offset++, 0x66); // f
    buffer.setUint8(offset++, 0x6D); // m
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x20); // (space)
    buffer.setUint32(offset, 16, Endian.little); // chunk size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM format
    offset += 2;
    buffer.setUint16(offset, channels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(
      offset,
      sampleRate * channels * (bitsPerSample ~/ 8),
      Endian.little,
    );
    offset += 4;
    buffer.setUint16(offset, channels * (bitsPerSample ~/ 8), Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;

    // data chunk
    buffer.setUint8(offset++, 0x64); // d
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // Write samples as 16-bit PCM
    for (final sample in samples) {
      final intSample = (sample * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }
}

/// Custom audio source for synthetic audio data.
class _SyntheticAudioSource extends StreamAudioSource {
  _SyntheticAudioSource(this._data);

  final Uint8List _data;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final effectiveStart = start ?? 0;
    final effectiveEnd = end ?? _data.length;

    return StreamAudioResponse(
      sourceLength: _data.length,
      contentLength: effectiveEnd - effectiveStart,
      offset: effectiveStart,
      stream: Stream.value(_data.sublist(effectiveStart, effectiveEnd)),
      contentType: 'audio/wav',
    );
  }
}
