#!/usr/bin/env bash
set -euo pipefail
flutter create --project-name fuzzleaf --org cc.ananwanan --platforms=windows,android,ios .
flutter pub get
flutter doctor -v
