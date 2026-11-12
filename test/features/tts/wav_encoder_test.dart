import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzleaf/features/tts/wav_encoder.dart';

void main() {
  group('encodePcm16Wav', () {
    test('writes a standard 44 byte mono PCM header', () {
      final encoded = encodePcm16Wav(Float32List.fromList([0, 1, -1]), 24000);
      final view = ByteData.sublistView(encoded);

      expect(String.fromCharCodes(encoded.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(encoded.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(encoded.sublist(36, 40)), 'data');
      expect(view.getUint32(4, Endian.little), 42);
      expect(view.getUint16(22, Endian.little), 1);
      expect(view.getUint16(34, Endian.little), 16);
      expect(view.getUint32(24, Endian.little), 24000);
      expect(view.getUint32(40, Endian.little), 6);
      expect(encoded.length, 50);
      expect(view.getInt16(44, Endian.little), 0);
      expect(view.getInt16(46, Endian.little), 32767);
      expect(view.getInt16(48, Endian.little), -32768);
    });

    test('rejects invalid sample rates', () {
      expect(
        () => encodePcm16Wav(Float32List(0), 0),
        throwsArgumentError,
      );
    });
  });
}
