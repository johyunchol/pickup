# app_ui

pickup 의 Flutter 앱들이 같이 쓰는 디자인 토큰과 테마.

- `lib/src/tokens.g.dart` — 생성 파일. 원본은 `packages/tokens/tokens.json`, `pnpm tokens:generate` 로 다시 만든다.
- `pickupTheme()` — 토큰으로 만든 `ThemeData`. 앱의 `MaterialApp.theme` 에 넣는다.

글꼴(Noto Sans KR)은 아직 번들하지 않아서, 기기에 없으면 기본 한글 글꼴로 보인다.
