import 'dart:typed_data';

/// Encodes mono normalized float PCM samples as a standard RIFF PCM16 WAV.
Uint8List encodePcm16Wav(Float32List samples, int sampleRate) {
  if (sampleRate <= 0) {
    throw ArgumentError.value(sampleRate, 'sampleRate', 'Must be positive');
  }
  const headerSize = 44;
  const bytesPerSample = 2;
  final dataSize = samples.length * bytesPerSample;
  final buffer = ByteData(headerSize + dataSize);

  void tag(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      buffer.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little);
  buffer.setUint16(22, 1, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * bytesPerSample, Endian.little);
  buffer.setUint16(32, bytesPerSample, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  buffer.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    final value = samples[i].clamp(-1.0, 1.0).toDouble();
    final scaled = value < 0 ? value * 32768 : value * 32767;
    buffer.setInt16(headerSize + i * 2, scaled.round(), Endian.little);
  }
  return buffer.buffer.asUint8List();
}
