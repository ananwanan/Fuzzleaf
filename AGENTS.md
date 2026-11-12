# Working agreements

- Product: Fuzzleaf, a fully offline audiobook application for Windows, Android, and iOS.
- Use Flutter/Dart and sherpa-onnx for M0; do not introduce network APIs, cloud TTS, or Python at runtime.
- Source-code comments and identifiers should be in English; user-facing copy may be Simplified Chinese.
- Keep a clean TTS engine boundary. Never run blocking ONNX inference on the UI isolate.
- Model files must not be committed to Git; document their provenance and redistributable licenses.
- Add tests for pure logic and update docs/ROADMAP.md when completing milestones.
- Do not claim a platform is validated until a real device/build has been tested.
- Avoid unrelated changes to LICENSE or history.
