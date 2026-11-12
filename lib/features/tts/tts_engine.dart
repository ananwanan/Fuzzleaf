import 'dart:typed_data';

class TtsAudio {
  final Float32List samples;
  final int sampleRate;

  const TtsAudio({required this.samples, required this.sampleRate});
}

abstract interface class TtsEngine {
  Future<void> initialize();

  Future<TtsAudio> synthesize(
    String text, {
    required int speakerId,
    double speed = 1.0,
  });

  Future<void> dispose();
}
