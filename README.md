# Fuzzleaf · 绒页

**A cozy, private, fully offline AI audiobook reader.**  
**温柔的故事，留在本地。**

Fuzzleaf is a Flutter application targeting **Windows, Android and iOS**. It will import local TXT/EPUB novels and turn them into speech *on the device*, without sending books or voices to a server.

> **Project status: M0 bootstrap (experimental).** This repository currently contains a text-to-speech proof of concept, not a finished audiobook player. EPUB import, background playback, library management and continuous chapter synthesis are not yet implemented.

## Stack

- Flutter + Dart (shared desktop/mobile UI)
- sherpa-onnx 2.0.1 + Kokoro-82M INT8 Chinese/English (on-device TTS)
- just_audio (playback), just_audio_media_kit (Windows backend)
- Planned: SQLite/Drift, TXT/EPUB parsing, audio cache, background audio controls

## Setup

Requires a current Flutter stable SDK with Dart >= 3.13. Native host folders are **generated locally**, because the repository intentionally keeps platform-generated boilerplate out of the initial M0 commit.

```powershell
git clone https://github.com/ananwanan/Fuzzleaf.git
cd Fuzzleaf
flutter create --project-name fuzzleaf --org cc.ananwanan --platforms=windows,android,ios .
flutter pub get
flutter doctor -v
```

Run with `flutter run -d windows` or `flutter run -d <android-device-id>`. iOS builds require macOS + Xcode. On Windows, enable Windows desktop development in Flutter and install Visual Studio C++ desktop tools. Check `flutter devices` for target IDs.

**Important: The model is NOT committed.** To enable synthesis, download the official `kokoro-int8-multi-lang-v1_1.tar.bz2` release from [sherpa-onnx TTS models](https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models). Unpack these files into `assets/models/kokoro-int8-multi-lang-v1_1/`:

```text
model.int8.onnx
voices.bin
tokens.txt
lexicon-us-en.txt
lexicon-zh.txt
date-zh.fst
number-zh.fst
phone-zh.fst
```

The checked-in `README.txt` keeps this directory present. Add the model files **before building the application**, then run `flutter pub get` and `flutter run`. The app copies the bundled model once to app support storage. Chinese voice samples are speaker IDs **3** and **58**; the official model has 103 speaker IDs.

The model needs to be downloaded once by the developer/package builder; **the app itself performs no downloads or network requests**. For release, distribute the properly licensed model assets inside the installer/APK/IPA; do not ship an empty prototype. Keep third-party model license notices with any redistributed build.

## Commands

```sh
flutter analyze
flutter test
flutter run -d windows
```

## Current M0 capabilities

- Warm, responsive Material 3 text-to-speech test screen
- Offline Kokoro model validation and local asset extraction
- Background isolate for blocking native inference
- Chinese voice presets, synthesis timing and real-time factor (RTF)
- PCM16 WAV output and device-local playback
- Testable WAV encoder and model-path configuration

## Roadmap

See [docs/ROADMAP.md](docs/ROADMAP.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/M0_VALIDATION.md](docs/M0_VALIDATION.md).

## License

Source code is under [MIT](LICENSE). Model weights, voices, language resources and native runtimes have their **own** licenses and must be audited separately before distribution.
