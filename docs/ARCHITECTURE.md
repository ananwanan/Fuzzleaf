# Architecture / 技术架构

```text
Flutter UI (Windows / Android / iOS)
  └─ application features
     ├─ library / reader / settings   [M1+]
     ├─ playback controller           [M0 prototype / M3 production]
     ├─ TtsEngine                     [M0]
     │   └─ SherpaOnnxTtsEngine
     │       ├─ ModelAssets (bundled -> application support storage)
     │       └─ dedicated Isolate (sherpa-onnx FFI, blocking inference)
     └─ audio cache and SQLite        [M1/M4]
```

## Model lifecycle

M0 bundles a pre-downloaded Kokoro INT8 model in Flutter assets. The app checks the eight required files and copies them to a private application-support folder, then sends absolute file paths in an OfflineTtsConfig to a long-lived isolate. The isolate initializes native bindings and loads the model once. A generation request returns samples and sample rate. The UI isolate encodes a local WAV file and passes its path to just_audio.

No cloud inference, download-at-runtime, tracking SDK, HTTP server or Python worker is used.

## Architectural rules

1. Inference MUST NOT block UI. Isolate owns and releases native TTS instance.
2. Separate model artifacts from books and generated audio; use app support storage.
3. Do not assume lock-screen inference is permitted on iOS: pre-generate in foreground and play cached audio.
4. Treat model-provided speaker IDs as model-specific; never hardcode them as universal presets.
5. M2 should add cancellation, backpressure, error recovery, cache invalidation and chunk/paragraph scheduling.

## M0 limitations

- M0 generates a single short paragraph per request; it does not yet synthesize whole novels.
- Bundled model assets increase install size. Future versions need a deliberate offline-install workflow.
- UI smoke tests are separate from device tests. Media backend behavior must be checked on every platform.
