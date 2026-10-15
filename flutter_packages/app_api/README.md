# app_api

pickup api 의 Dart 클라이언트 (`PickupApi`, `MenuItem`, `Order` …).

`lib/src/generated` 는 생성 파일입니다. 손으로 고치지 말고 원본을 고친 뒤 다시 만드세요.

```
packages/contract (zod) + apps/api (Nest 컨트롤러)
  → openapi/openapi.json                       @nestjs/swagger
  → lib/src/generated/**.dart                  swagger_parser (swagger_parser.yaml)
  → lib/src/generated/**.g.dart                build_runner (retrofit_generator · json_serializable)
```

```bash
pnpm api:generate   # 다시 만들기
pnpm api:check      # 작업본이 원본과 같은지 확인 (다르면 실패)
```

```dart
final api = PickupApi(Dio(BaseOptions(baseUrl: 'http://localhost:4000')));
final menu = await api.menu.listMenu();
final order = await api.orders.createOrder(body: CreateOrderBody(...));
```

2xx 가 아니면 `DioException` 이 난다. 서버가 보낸 메시지는 `e.serverMessage` (`lib/src/api_error.dart`).
