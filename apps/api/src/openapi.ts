import type { INestApplication } from "@nestjs/common";
import { DocumentBuilder, SwaggerModule, type OpenAPIObject } from "@nestjs/swagger";

/** 컨트롤러의 데코레이터(경로·@Body/@Param 스키마·@ContractResponse)에서 OpenAPI 문서를 만든다. */
export function createOpenApiDocument(app: INestApplication): OpenAPIObject {
  const config = new DocumentBuilder()
    .setTitle("pickup api")
    .setVersion("0.1.0")
    .setDescription("생성 파일 — 고치지 마세요. 원본: apps/api 의 컨트롤러와 packages/contract (pnpm api:generate)")
    .build();
  return SwaggerModule.createDocument(app, config, {
    // operationId 는 컨트롤러 메서드 이름 그대로 — Dart 클라이언트의 메서드 이름이 된다.
    operationIdFactory: (_controllerKey, methodKey) => methodKey,
  });
}
