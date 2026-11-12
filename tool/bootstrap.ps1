# Run from the repository root (Windows PowerShell).
$ErrorActionPreference = "Stop"
flutter create --project-name fuzzleaf --org cc.ananwanan --platforms=windows,android,ios .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter doctor -v
