import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'model_assets.dart';
import 'tts_engine.dart';

class SherpaOnnxTtsEngine implements TtsEngine {
  Isolate? _worker;
  SendPort? _commands;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    final config = await prepareKokoroModel();
    final ready = ReceivePort();
    try {
      _worker = await Isolate.spawn(_ttsWorkerMain, ready.sendPort);
      _commands = await ready.first.timeout(const Duration(seconds: 15))
          as SendPort;
      await _request({'type': 'init', 'config': config});
      _initialized = true;
    } catch (_) {
      _worker?.kill(priority: Isolate.immediate);
      _worker = null;
      _commands = null;
      rethrow;
    } finally {
      ready.close();
    }
  }

  Future<Map<dynamic, dynamic>> _request(Map<String, Object> request) async {
    final commands = _commands;
    if (commands == null) throw StateError('TTS engine has not started.');
    final responsePort = ReceivePort();
    try {
      commands.send({...request, 'reply': responsePort.sendPort});
      final response = await responsePort.first.timeout(
        const Duration(minutes: 5),
      ) as Map<dynamic, dynamic>;
      if (response['ok'] != true) {
        throw StateError('${response["error"] ?? "Unknown native error"}');
      }
      return response;
    } finally {
      responsePort.close();
    }
  }

  @override
  Future<TtsAudio> synthesize(
    String text, {
    required int speakerId,
    double speed = 1.0,
  }) async {
    if (!_initialized) throw StateError('TTS engine is not initialized.');
    if (text.trim().isEmpty) throw ArgumentError('Text must not be empty.');
    final output = await _request({
      'type': 'generate',
      'text': text,
      'speakerId': speakerId,
      'speed': speed,
    });
    return TtsAudio(
      samples: output['samples'] as Float32List,
      sampleRate: output['sampleRate'] as int,
    );
  }

  @override
  Future<void> dispose() async {
    if (_commands != null) {
      try {
        await _request({'type': 'dispose'})
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        // A crashed native worker must never block application shutdown.
      }
    }
    _worker?.kill(priority: Isolate.immediate);
    _worker = null;
    _commands = null;
    _initialized = false;
  }
}

/// The long-lived worker owns the native TTS instance.
void _ttsWorkerMain(SendPort initialReply) {
  final messages = ReceivePort();
  initialReply.send(messages.sendPort);
  sherpa.OfflineTts? engine;

  messages.listen((message) {
    if (message is! Map) return;
    final reply = message['reply'] as SendPort;
    try {
      switch (message['type']) {
        case 'init':
          sherpa.initBindings(); // Bindings must be initialized per isolate.
          engine?.free();
          engine = sherpa.OfflineTts(
            message['config'] as sherpa.OfflineTtsConfig,
          );
          reply.send({'ok': true});
        case 'generate':
          final current = engine;
          if (current == null) {
            throw StateError('Native TTS has not been initialized.');
          }
          final audio = current.generateWithConfig(
            text: message['text'] as String,
            config: sherpa.OfflineTtsGenerationConfig(
              sid: message['speakerId'] as int,
              speed: message['speed'] as double,
            ),
          );
          reply.send({
            'ok': true,
            'samples': Float32List.fromList(audio.samples),
            'sampleRate': audio.sampleRate,
          });
        case 'dispose':
          engine?.free();
          engine = null;
          reply.send({'ok': true});
          messages.close();
        default:
          throw ArgumentError('Unknown worker command.');
      }
    } catch (error) {
      reply.send({'ok': false, 'error': '$error'});
    }
  });
}
