# AGENTS.md — 이 저장소에서 일하는 AI 에이전트용 규칙

카페 픽업 주문 샘플. JS 는 pnpm workspace + Turborepo, Flutter 는 루트 `pubspec.yaml` 의 Dart pub workspace.

## 구조
- `apps/api` 서버(NestJS, 포트 4000) · `apps/web` 사장님 웹(Next.js, 포트 3000) · `apps/app` 손님 앱(Flutter)
- `packages/contract` 메뉴·주문 데이터 모양의 원본(zod) · `packages/tokens` 디자인 토큰 원본(`tokens.json`)
- 생성물: `openapi/openapi.json`, `flutter_packages/app_api/lib/src/generated/`, `packages/tokens/generated/`, `flutter_packages/app_ui/lib/src/tokens.g.dart`
- `flutter_packages/` 앱들이 같이 쓰는 Dart 패키지 · `tools/` 검사·생성 스크립트

## 규칙
- 계약(`packages/contract` 스키마, `apps/api` 컨트롤러)을 바꾸면 같은 변경에서 `pnpm api:generate`.
- 토큰(`packages/tokens/tokens.json`)을 바꾸면 같은 변경에서 `pnpm tokens:generate`.
- 생성물은 손으로 고치지 않는다 — 원본을 고치고 다시 생성한다.
- 손님 앱의 api 호출은 생성 클라이언트(`PickupApi`)만 쓴다. 손으로 쓴 모델·호출 코드를 두지 않는다.
- 포트 4000 이 쓰이고 있으면 `PORT=4100 API_URL=http://localhost:4100 pnpm dev`. 테스트는 포트 0(임의 포트)을 쓴다.
- 새 Flutter 앱·패키지는 루트 `pubspec.yaml` workspace 와 `tools/verify_mobile.sh` 에 같이 추가한다.

## 완료 기준
`pnpm verify` 통과. 마지막 요약에 ✘ 가 하나라도 있으면 끝난 게 아니다.
(JS 만 빠르게: `pnpm verify:js`, Flutter 만: `pnpm verify:mobile`)
