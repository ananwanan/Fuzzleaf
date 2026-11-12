import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'app/fuzzleaf_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    JustAudioMediaKit.ensureInitialized(
      windows: true,
      linux: false,
    );
  }
  runApp(const FuzzleafApp());
}
