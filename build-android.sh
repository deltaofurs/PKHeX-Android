#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

./setup-pkhex.sh

echo "[1/3] Running platform-independent PKHeX smoke tests..."
dotnet run --project ./PKHeX.Android.SmokeTests/PKHeX.Android.SmokeTests.csproj -c Release

echo "[2/3] Restoring Android workload/project..."
dotnet workload restore ./PKHeX.Android/PKHeX.Android.csproj
dotnet restore ./PKHeX.Android/PKHeX.Android.csproj

echo "[3/3] Publishing Release APK..."
dotnet publish ./PKHeX.Android/PKHeX.Android.csproj -f net10.0-android -c Release --no-restore

echo "Build gate passed. Check PKHeX.Android/bin/Release/net10.0-android/publish for the APK."
