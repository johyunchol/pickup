#!/usr/bin/env bash
# 저장소 전체 검사 — `pnpm verify`(js + mobile)와 `pnpm verify:js` 의 본체.
#   bash tools/verify.sh       JS 검사 + Flutter 검사
#   bash tools/verify.sh js    JS 검사만 (turbo typecheck·lint·test·build, api:check, tokens:check)
# 첫 실패에서 멈추지 않고 끝까지 돌린 뒤 단계별 ✔/✘ 를 요약한다. 하나라도 실패면 종료 코드 1.
# (macOS 기본 bash 3.2 에서도 돌게 연관 배열 없이 쓴다)
set -uo pipefail

cd "$(dirname "$0")/.."

# 단계 이름|명령. 새 검사는 여기에 한 줄 추가한다.
STEPS=(
  "typecheck|pnpm exec turbo run typecheck --continue"
  "lint|pnpm exec turbo run lint --continue"
  "test|pnpm exec turbo run test --continue"
  "build|pnpm exec turbo run build --continue"
  "api:check|pnpm api:check"
  "tokens:check|pnpm tokens:check"
)
case "${1:-all}" in
  js) ;;
  all) STEPS+=("verify:mobile|bash tools/verify_mobile.sh") ;;
  *) echo "사용법: bash tools/verify.sh [js]" >&2; exit 2 ;;
esac

if [[ -t 1 ]]; then
  BOLD=$'\e[1m' RED=$'\e[31m' GREEN=$'\e[32m' DIM=$'\e[2m' RESET=$'\e[0m'
else
  BOLD='' RED='' GREEN='' DIM='' RESET=''
fi

tmp="${TMPDIR:-/tmp}"
LOG_DIR="$(mktemp -d "${tmp%/}/pickup-verify.XXXXXX")"
NAMES=() RESULTS=() TIMES=() LOGS=()
failed=0

for step in "${STEPS[@]}"; do
  name="${step%%|*}"
  cmd="${step#*|}"
  log="$LOG_DIR/${name//:/_}.log"
  echo
  echo "${BOLD}▶ $name${RESET} ${DIM}($cmd)${RESET}"
  start=$SECONDS
  bash -c "$cmd" 2>&1 | tee "$log"
  code=${PIPESTATUS[0]}
  NAMES+=("$name") TIMES+=($((SECONDS - start))) LOGS+=("$log") RESULTS+=("$code")
  [[ $code -ne 0 ]] && failed=$((failed + 1))
done

echo
echo "${BOLD}━━ verify 요약 ━━${RESET}"
for i in "${!NAMES[@]}"; do
  if [[ ${RESULTS[$i]} -eq 0 ]]; then
    printf '  %s✔%s %-14s %4ss\n' "$GREEN" "$RESET" "${NAMES[$i]}" "${TIMES[$i]}"
  else
    printf '  %s✘ %-14s %4ss  (종료 코드 %s)%s\n' "$RED" "${NAMES[$i]}" "${TIMES[$i]}" "${RESULTS[$i]}" "$RESET"
  fi
done

if [[ $failed -eq 0 ]]; then
  rm -rf "$LOG_DIR"
  echo "${GREEN}${BOLD}✔ 모두 통과${RESET}"
  exit 0
fi

# 실패한 단계마다 로그 끝부분을 다시 보여 준다 — 위로 스크롤하지 않아도 이유가 보이게.
for i in "${!NAMES[@]}"; do
  [[ ${RESULTS[$i]} -eq 0 ]] && continue
  echo
  echo "${RED}${BOLD}✘ ${NAMES[$i]} — 로그 마지막 20줄${RESET} ${DIM}(전체: ${LOGS[$i]})${RESET}"
  grep -v '^[[:space:]]*$' "${LOGS[$i]}" | tail -n 20 | sed 's/^/    /'
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::error title=verify: ${NAMES[$i]} 실패::$(grep -v '^[[:space:]]*$' "${LOGS[$i]}" | tail -n 1)"
  fi
done
echo
echo "${RED}${BOLD}✘ ${failed}개 단계 실패${RESET}"
exit 1
