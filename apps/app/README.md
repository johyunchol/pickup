# pickup_app

pickup 손님 앱 (Flutter, iOS·Android). 메뉴 → 주문(닉네임) → 내 주문 상태(3초마다 갱신).

api 호출은 생성 클라이언트 `flutter_packages/app_api` 의 `PickupApi` 만 쓴다 — 손으로 쓴 모델·호출 코드를 두지 않는다.
api 모양이 바뀌면 `packages/contract`(스키마)·`apps/api`(컨트롤러)를 고치고 저장소 루트에서 `pnpm api:generate`.

글꼴 Noto Sans KR 은 google_fonts 가 처음 쓸 때 내려받아 기기에 캐시한다 (`flutter_packages/app_ui`).

```bash
# 저장소 루트에서 api 를 먼저 띄운다
pnpm --filter @pickup/api dev

# iOS 시뮬레이터 (기본값 http://localhost:4000)
flutter run

# Android 에뮬레이터 — 에뮬레이터 안의 localhost 는 자기 자신이라 10.0.2.2 로 부른다
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```
