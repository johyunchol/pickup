#!/usr/bin/env bash
# Flutter 쪽(Dart pub workspace) 검사 — `pnpm verify:mobile` 의 본체.
# pub get 은 워크스페이스 루트에서 한 번, analyze·test 는 앱과 패키지마다 돈다.
set -euo pipefail

cd "$(dirname "$0")/.."

# 새 앱·패키지는 여기와 루트 pubspec.yaml 의 workspace 목록에 같이 추가한다.
MEMBERS=(
  apps/app
  flutter_packages/app_core
)

echo "▶ flutter pub get"
flutter pub get

for dir in "${MEMBERS[@]}"; do
  echo "▶ $dir: flutter analyze"
  (cd "$dir" && flutter analyze)
  echo "▶ $dir: flutter test"
  (cd "$dir" && flutter test)
done

echo "✔ verify:mobile 통과"
