#!/usr/bin/env bash
# openapi/openapi.json → flutter_packages/app_api/lib/src/generated
#   bash tools/api_dart.sh          다시 만든다 (swagger_parser → build_runner)
#   bash tools/api_dart.sh --check  다시 만들어 보고, 전과 다르면 되돌린 뒤 실패한다
# 설정은 flutter_packages/app_api/swagger_parser.yaml. 루트의 pnpm api:generate · api:check 가 부른다.
set -euo pipefail

cd "$(dirname "$0")/../flutter_packages/app_api"
OUT=lib/src/generated

generate() {
  # 지운 스키마의 파일이 남지 않게 통째로 다시 만든다.
  rm -rf "$OUT"
  dart run swagger_parser
  dart run build_runner build
}

if [[ "${1:-}" != "--check" ]]; then
  generate
  echo "▶ flutter_packages/app_api/$OUT"
  exit 0
fi

before="$(mktemp -d)"
trap 'rm -rf "$before"' EXIT
if [[ -d "$OUT" ]]; then cp -R "$OUT" "$before/generated"; else mkdir "$before/generated"; fi

generate > /dev/null
if diff -r "$before/generated" "$OUT"; then
  echo "✔ flutter_packages/app_api/$OUT"
else
  rm -rf "$OUT"
  cp -R "$before/generated" "$OUT"
  echo "✘ flutter_packages/app_api/$OUT 가 openapi/openapi.json 과 다릅니다" >&2
  echo "pnpm api:generate 로 다시 만드세요." >&2
  exit 1
fi
