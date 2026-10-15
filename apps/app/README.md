# pickup_app

pickup 손님 앱 (Flutter, iOS·Android). 첫 화면에서 api 의 `GET /menu` 를 불러 메뉴를 보여 준다.

```bash
# 저장소 루트에서 api 를 먼저 띄운다
pnpm --filter @pickup/api dev

# iOS 시뮬레이터 (기본값 http://localhost:4000)
flutter run

# Android 에뮬레이터 — 에뮬레이터 안의 localhost 는 자기 자신이라 10.0.2.2 로 부른다
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```
