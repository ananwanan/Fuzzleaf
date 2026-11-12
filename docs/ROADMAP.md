# Fuzzleaf roadmap

## M0 — Feasibility & bootstrap (in progress)
- [x] Flutter application entry point and basic TTS demo UI
- [x] sherpa-onnx engine interface + background isolate
- [x] Kokoro INT8 model asset pipeline (builder-supplied model)
- [x] PCM WAV output, playback and simple RTF measurement
- [x] Unit tests for WAV encoding
- [ ] Validate Windows release build and audio output
- [ ] Validate Android arm64 release build on mid-range phone
- [ ] Validate iOS device build + signing on macOS
- [ ] Record peak RAM, startup time, battery and RTF by device
- [ ] License check of model and packaged resources

## M1 — Book library
- TXT UTF-8/GB18030 detection, EPUB parsing, chapters and metadata
- SQLite + Drift migration strategy, search and reading progress
- Unit tests for imports, very large files and malformed input

## M2 — Continuous narration
- Natural-language sentence segmentation and pronunciation normalization
- Bounded synthesis queue, audio prefetch, task generation IDs / cancellation
- Continuous chapter playback without duplicated or skipped sentences

## M3 — Listening experience
- Chapter skip, speed, sleep timer, bookmarks, resumed playback
- Android MediaSession / foreground service, iOS background audio
- Audio focus interruptions, Bluetooth/headset controls

## M4 — Cache and device optimization
- Deterministic content/model/voice/parameter cache keys
- LRU cleanup, offline chapter pre-generation, foreground iOS synthesis
- Memory budgets, thermal limits and low-resource model fallback

## M5 — Advanced reading
- Voice library, multiple installed engines, per-book settings
- Sentence highlighting, bookmarks and locally exported audiobooks

## M6 — Packaging & release
- Windows installer, Android APK/AAB and iOS TestFlight/IPA
- Offline release verification, accessibility, licenses and security review

The roadmap describes future milestones; M0 checkmarks mean source scaffolding exists, **not** that real-device validation passed.
