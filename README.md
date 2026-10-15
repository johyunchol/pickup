# pickup

카페 픽업 주문 샘플 — 사장님 웹(Next.js), 서버(NestJS), 손님 앱(Flutter)을 저장소 하나에서 만든다.

KKENSU LAB 유튜브 시리즈의 실습 저장소입니다. 편마다 태그(`ep1` …)를 찍어 두니, 영상의 그 지점부터 따라 하실 수 있습니다.

## 구성

| 위치 | 역할 |
|---|---|
| `apps/api` | 서버 (NestJS, 포트 4000) |
| `apps/web` | 사장님 화면 (Next.js, 포트 3000) |
| `apps/app` | 손님 앱 (Flutter, iOS·Android) |
| `flutter_packages/` | Flutter 앱들이 같이 쓰는 Dart 패키지 (`app_core` …) |

JS 쪽은 pnpm workspace + Turborepo, Flutter 쪽은 루트 `pubspec.yaml` 의 Dart pub workspace 로 묶는다.

```bash
pnpm install
pnpm dev      # 서버와 사장님 화면을 같이 띄웁니다 (Flutter 앱은 뜨지 않음)
pnpm verify:mobile   # Flutter 쪽 pub get → 앱·패키지마다 analyze, test
```

손님 앱 실행은 [apps/app/README.md](apps/app/README.md) 참고.

4000번 포트를 다른 프로그램이 쓰고 있으면 `PORT=4100 API_URL=http://localhost:4100 pnpm dev`.

## 만든 시점의 버전 (2026-10)

Node 26.7 · pnpm 12.8.1 · Turborepo 2.11.8 · Next.js 16.4.0 · NestJS 12.1.3 · TypeScript 6.0.3 · Flutter 3.47.5 · Dart 3.13.4

pnpm 은 출시된 지 얼마 안 된 패키지 설치를 막습니다(공급망 보호). 그래서 버전이 하루 이틀 전 것일 수 있습니다.

## 라이선스

[MIT](LICENSE)
