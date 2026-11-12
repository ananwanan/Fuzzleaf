import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../features/tts/sherpa_tts_engine.dart';
import '../features/tts/wav_encoder.dart';

class FuzzleafApp extends StatelessWidget {
  const FuzzleafApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFB28598);
    return MaterialApp(
      title: '绒页 · Fuzzleaf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F6),
      ),
      home: const NarrationLabPage(),
    );
  }
}

class NarrationLabPage extends StatefulWidget {
  const NarrationLabPage({super.key});

  @override
  State<NarrationLabPage> createState() => _NarrationLabPageState();
}

class _NarrationLabPageState extends State<NarrationLabPage> {
  final _text = TextEditingController(
    text: '窗外下着细雨。小猫趴在温暖的书页旁，静静听着故事。晚安，今天也辛苦啦。',
  );
  final _engine = SherpaOnnxTtsEngine();
  final _player = AudioPlayer();
  int _speakerId = 3;
  bool _busy = false;
  bool _ready = false;
  String _status = '准备就绪。首次生成前，请将 Kokoro 模型放入 assets/models 目录并重新构建。';
  double? _rtf;
  double? _duration;
  Duration _elapsed = Duration.zero;
  String? _lastWav;

  Future<void> _generate() async {
    if (_busy) return;
    final text = _text.text.trim();
    if (text.isEmpty) {
      setState(() => _status = '请输入需要朗读的文字。');
      return;
    }

    setState(() {
      _busy = true;
      _status = '正在准备本地语音模型…';
    });

    try {
      await _player.stop();
      if (!_ready) {
        await _engine.initialize();
        _ready = true;
      }
      if (mounted) setState(() => _status = '正在离线生成语音…');

      final stopwatch = Stopwatch()..start();
      final result = await _engine.synthesize(text, speakerId: _speakerId);
      stopwatch.stop();
      final audioDuration = result.samples.length / result.sampleRate;
      if (audioDuration <= 0) {
        throw StateError('The model generated an empty audio buffer.');
      }

      final directory = await getTemporaryDirectory();
      final file = File(p.join(directory.path, 'fuzzleaf-preview.wav'));
      await file.writeAsBytes(
        encodePcm16Wav(result.samples, result.sampleRate),
        flush: true,
      );
      _lastWav = file.path;
      _rtf = stopwatch.elapsedMilliseconds / (audioDuration * 1000);
      _duration = audioDuration;
      _elapsed = stopwatch.elapsed;
      await _player.setFilePath(file.path);
      if (!mounted) return;
      setState(() => _status = '生成成功，正在播放。');
      unawaited(_player.play());
    } catch (error) {
      if (mounted) {
        setState(() => _status = '生成失败：$error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    unawaited(_player.dispose());
    unawaited(_engine.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('绒页 · Fuzzleaf'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card.filled(
                color: colors.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 40),
                      SizedBox(height: 12),
                      Text('把故事，轻轻讲给你听。',
                          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('完全本地 AI 听书 · M0 语音技术验证'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('朗读内容', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _text,
                maxLines: 6,
                maxLength: 400,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入一小段中文文本…',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _speakerId,
                decoration: const InputDecoration(
                  labelText: '中文音色',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('温柔女声 · zf_001')),
                  DropdownMenuItem(value: 58, child: Text('沉稳男声 · zm_009')),
                ],
                onChanged: _busy
                    ? null
                    : (value) {
                        if (value != null) setState(() => _speakerId = value);
                      },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : _generate,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.graphic_eq),
                label: Text(_busy ? '生成中…' : '离线生成并播放'),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _lastWav == null ? null : _player.pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('暂停'),
                  ),
                  TextButton.icon(
                    onPressed: _lastWav == null
                        ? null
                        : () async {
                            await _player.seek(Duration.zero);
                            unawaited(_player.play());
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('重听'),
                  ),
                  TextButton.icon(
                    onPressed: _lastWav == null ? null : _player.stop,
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('运行状态', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_status),
                      if (_duration != null) ...[
                        const SizedBox(height: 8),
                        Text('音频时长：${_duration!.toStringAsFixed(2)} 秒'),
                        Text('推理耗时：${_elapsed.inMilliseconds} ms'),
                        Text('RTF：${_rtf!.toStringAsFixed(3)}'),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        '无需联网。首次运行需要将已下载的模型随应用打包。',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
