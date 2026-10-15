# pickup

카페 픽업 주문 샘플 — 사장님 웹(Next.js), 서버(NestJS), 손님 앱(Flutter)을 저장소 하나에서 만든다.

KKENSU LAB 유튜브 시리즈의 실습 저장소입니다. 편마다 태그(`ep1` …)를 찍어 두니, 영상의 그 지점부터 따라 하실 수 있습니다.

## 구성

| 위치 | 역할 |
|---|---|
| `apps/api` | 서버 (NestJS, 포트 4000) |
| `apps/web` | 사장님 화면 (Next.js, 포트 3000) |
| `apps/app` | 손님 앱 (Flutter, iOS·Android) |
| `packages/contract` | 메뉴·주문 데이터 모양의 원본 — zod 스키마 ([왜 이렇게?](packages/contract/README.md)) |
| `packages/tokens` | 디자인 토큰 원본 — 웹 CSS 변수와 앱 Dart 상수를 만든다 |
| `openapi/openapi.json` | 서버(Nest 컨트롤러 + zod 스키마)에서 생성한 OpenAPI 문서 |
| `flutter_packages/` | Flutter 앱들이 같이 쓰는 Dart 패키지 (`app_api` 생성 클라이언트, `app_core`, `app_ui` …) |

화면 디자인은 `design/pickup.pen` (Pencil) — 사장님 주문 보드·메뉴 관리, 손님 메뉴·내 주문 상태.

## 기능

- 메뉴 6개(커피·논커피·디저트, 하나는 품절로 시작). 사장님이 품절을 켜고 끈다.
- 손님은 로그인 없이 닉네임 + 메뉴·수량 여러 개로 주문한다. 결제는 매장에서.
- 주문 번호는 하루 단위로 1번부터. 상태는 접수 → 제조 중 → 픽업 대기 → 완료, 사장님만 넘긴다.
- 사장님 웹·손님 앱 모두 3초마다 다시 불러온다(폴링). 저장은 메모리 — 서버를 다시 켜면 사라진다.

JS 쪽은 pnpm workspace + Turborepo, Flutter 쪽은 루트 `pubspec.yaml` 의 Dart pub workspace 로 묶는다.

```bash
pnpm install
pnpm dev      # 서버와 사장님 화면을 같이 띄웁니다 (Flutter 앱은 뜨지 않음)
pnpm verify:mobile   # Flutter 쪽 pub get → 앱·패키지마다 analyze, test
pnpm api:generate    # 스키마·컨트롤러를 고친 뒤 → openapi.json → Dart 클라이언트 다시 만들기
pnpm api:check       # 생성물이 서버 코드와 같은지 확인 (다르면 실패)
pnpm tokens:check    # 디자인 토큰 생성물 확인
```

손님 앱 실행은 [apps/app/README.md](apps/app/README.md) 참고.

4000번 포트를 다른 프로그램이 쓰고 있으면 `PORT=4100 API_URL=http://localhost:4100 pnpm dev`.

## 만든 시점의 버전 (2026-10)

Node 26.7 · pnpm 12.8.1 · Turborepo 2.11.8 · Next.js 16.4.0 · NestJS 12.1.3 · @nestjs/swagger 12.0.2 · TypeScript 6.0.3 · zod 4.6.7 · Flutter 3.47.5 · Dart 3.13.4 · swagger_parser 1.45.0 · retrofit 4.10.0 · dio 5.11.1 · google_fonts 9.0.0

pnpm 은 출시된 지 얼마 안 된 패키지 설치를 막습니다(공급망 보호). 그래서 버전이 하루 이틀 전 것일 수 있습니다.

## 라이선스

[MIT](LICENSE)
