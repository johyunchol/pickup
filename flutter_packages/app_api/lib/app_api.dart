/// pickup api 의 Dart 클라이언트.
///
/// `src/generated` 는 openapi/openapi.json(서버가 만든 문서)에서 swagger_parser 와
/// build_runner 로 생성한다. 손으로 고치지 말고 `pnpm api:generate`.
library;

export 'src/api_error.dart';
export 'src/generated/export.dart';
