# M0 acceptance checklist

The current repo is an **unvalidated prototype**. Run tests locally before marking M0 complete.

## Setup
1. Install a supported Flutter SDK, Android SDK, VS C++ desktop and (for iOS) Xcode.
2. Run `flutter create --project-name fuzzleaf --org cc.ananwanan --platforms=windows,android,ios .`.
3. Download and unpack the official Kokoro INT8 1.1 Chinese-English model.
4. Copy the eight required files listed in README to assets/models/kokoro-int8-multi-lang-v1_1.
5. Run `flutter pub get && flutter analyze && flutter test`.

## Device matrix

| Device | Build | Native TTS | Offline mode | RTF | Peak RAM |
|---|---|---|---|---|---|
| Windows 11 x64 | TODO | TODO | TODO | TODO | TODO |
| Android arm64 | TODO | TODO | TODO | TODO | TODO |
| iOS arm64 | TODO | TODO | TODO | TODO | TODO |

## Cases
- Voice IDs 3 and 58 can read Chinese sample without a remote connection.
- Play, pause and stop behave correctly. Repeated synthesis does not crash.
- UI stays responsive while generating, including during long samples.
- Number/Latin/acronym mixed text does not silently crash the engine.
- Check after process restart and fresh install.
- Check behavior when the model is missing or corrupt.
- Record warm/cold initialization, synthesized audio length, generation time and RTF.
- Check thermal behavior and energy on mid-range phones.
- Confirm bundled licensing notices before redistributing model files.

Do not claim a successful device test unless these results are actually recorded.
