# @pickup/contract

pickup 의 데이터 모양 원본. 메뉴·주문의 zod 스키마가 여기 하나뿐이다.

```
src/menu.ts, src/order.ts   zod 스키마 (MenuItem, Order, CreateOrderBody …)
src/params.ts               경로 파라미터 (IdParam — "/orders/7" 의 7 을 숫자로)
```

스키마마다 `.meta({ id: "Order" })` 처럼 id 를 붙인다. 이 id 가 OpenAPI 문서의 `components.schemas` 이름이 되고, 그 이름이 그대로 Dart 클래스 이름이 된다.

| 누가 | 어떻게 쓰나 |
|---|---|
| 서버 `apps/api` (Nest) | `@Body({ schema: CreateOrderBody })`, `@Param("id", { schema: IdParam })` 로 요청을 검증하고, `@ContractResponse(Order)` 로 응답을 검증한다. 같은 데코레이터에서 `@nestjs/swagger` 가 `openapi/openapi.json` 을 만든다. |
| 사장님 웹 `apps/web` | 이 패키지를 그대로 import 한다 — 타입은 화면 코드에서, 스키마는 응답을 `parse` 하는 fetch 래퍼(`lib/api.ts`)에서. |
| 손님 앱 `apps/app` | import 할 수 없으니 `openapi/openapi.json` → `flutter_packages/app_api` (swagger_parser + build_runner) 로 생성해서 쓴다. |

스키마나 컨트롤러를 고쳤으면 저장소 루트에서:

```bash
pnpm api:generate   # Nest 앱을 init 만 해서 → openapi/openapi.json → swagger_parser → build_runner
pnpm api:check      # 다시 만든 결과가 작업본과 다르면 실패 (CI·커밋 전 확인용)
```

## 고른 이유 (2026-10, Nest 12 · zod 4 기준)

- **스키마 한 벌로 끝난다.** `nestjs-zod` 방식은 `class CreateOrderDto extends createZodDto(CreateOrderBody) {}` 처럼 스키마마다 DTO 클래스를 하나씩 더 만들어야 했다. Nest 12 는 [Standard Schema](https://standardschema.dev) 를 직접 받는다 — `@Body({ schema })` 에 zod 스키마를 그대로 넘기고, 전역 `StandardSchemaValidationPipe` 가 검증한다. DTO 클래스도, 그걸 위한 라이브러리도 없다.
- **응답도 검증한다.** 전역 `StandardSchemaSerializerInterceptor` 가 `@SerializeOptions({ schema })` 의 스키마로 응답을 검사한다. 핸들러가 스키마와 다른 모양을 돌려주면 500 이 난다 — "문서와 실제 응답이 다르다" 가 생기지 않는다. `@ContractResponse(schema)` 는 이 `SerializeOptions` 와 문서용 `@ApiResponse({ standardSchema })` 를 한 번에 붙이는 작은 데코레이터다.
- **추가 프레임워크가 없다.** 컨트롤러·라우팅·파이프·인터셉터 모두 Nest 기본 기능이고, OpenAPI 는 Nest 공식 `@nestjs/swagger` 가 같은 스키마(zod 의 `~standard.jsonSchema`)에서 만든다. 웹은 zod + `fetch`, 앱은 OpenAPI 생성기 중 Dart 쪽에서 가장 널리 쓰는 swagger_parser(Retrofit + json_serializable)를 쓴다 — 현업에서 그대로 만나는 도구들이다.
- **문서는 서버 코드에서 나온다.** 경로·메서드·상태 코드는 컨트롤러 데코레이터가 원본이라, 문서를 따로 관리하지 않는다. `pnpm api:check` 가 생성물이 서버 코드와 같은지 지켜 준다.
