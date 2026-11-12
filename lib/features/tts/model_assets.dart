import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

const _modelAssetPrefix = 'assets/models/kokoro-int8-multi-lang-v1_1/';
const _requiredFiles = <String>[
  'model.int8.onnx',
  'voices.bin',
  'tokens.txt',
  'lexicon-us-en.txt',
  'lexicon-zh.txt',
  'date-zh.fst',
  'number-zh.fst',
  'phone-zh.fst',
];

/// Copies bundled model artifacts to a path accessible to native ONNX code.
/// This is deliberately offline: nothing is downloaded at runtime.
Future<sherpa.OfflineTtsConfig> prepareKokoroModel() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final available = manifest.listAssets().toSet();
  final missing = _requiredFiles
      .where((name) => !available.contains('$_modelAssetPrefix$name'))
      .toList();
  if (missing.isNotEmpty) {
    throw StateError(
      'Kokoro model is not bundled. Missing: ${missing.join(", ")}. '
      'See README.md for the model installation steps.',
    );
  }

  final support = await getApplicationSupportDirectory();
  final dir = Directory(
    p.join(support.path, 'models', 'kokoro-int8-multi-lang-v1_1'),
  );
  await dir.create(recursive: true);
  for (final name in _requiredFiles) {
    final source = await rootBundle.load('$_modelAssetPrefix$name');
    final target = File(p.join(dir.path, name));
    if (!await target.exists() ||
        await target.length() != source.lengthInBytes) {
      await target.writeAsBytes(
        source.buffer.asUint8List(source.offsetInBytes, source.lengthInBytes),
        flush: true,
      );
    }
  }

  String file(String name) => p.join(dir.path, name);
  return sherpa.OfflineTtsConfig(
    model: sherpa.OfflineTtsModelConfig(
      kokoro: sherpa.OfflineTtsKokoroModelConfig(
        model: file('model.int8.onnx'),
        voices: file('voices.bin'),
        tokens: file('tokens.txt'),
        lexicon: '${file("lexicon-us-en.txt")},${file("lexicon-zh.txt")}',
      ),
      numThreads: 2,
      debug: false,
    ),
    ruleFsts: [
      file('phone-zh.fst'),
      file('date-zh.fst'),
      file('number-zh.fst'),
    ].join(','),
    maxNumSentences: 1,
  );
}
