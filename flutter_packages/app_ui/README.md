# app_ui

pickup 의 Flutter 앱들이 같이 쓰는 디자인 토큰과 테마.

- `lib/src/tokens.g.dart` — 생성 파일. 원본은 `packages/tokens/tokens.json`, `pnpm tokens:generate` 로 다시 만든다.
- `pickupTheme()` — 토큰으로 만든 `ThemeData`. 앱의 `MaterialApp.theme` 에 넣는다.

글꼴(Noto Sans KR 400·500·700)은 [google_fonts](https://pub.dev/packages/google_fonts) 가 처음 쓸 때 내려받아 기기에 캐시한다 — 저장소와 앱 번들에 글꼴 파일을 넣지 않는다.
테마의 글자 스타일과 다른 굵기를 쓰는 `TextStyle` 은 `pickupFont(...)` 로 감싼다 (google_fonts 는 굵기마다 파일이 따로라서).
