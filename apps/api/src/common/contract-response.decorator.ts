import { applyDecorators, HttpCode, HttpStatus, SerializeOptions } from "@nestjs/common";
import { ApiResponse } from "@nestjs/swagger";
import type { StandardSchemaV1 } from "@standard-schema/spec";

interface ContractResponseOptions {
  /** 성공 응답 코드 — 문서와 실제 응답이 같은 값을 쓴다 */
  status?: HttpStatus;
  /** 배열을 돌려준다 — 스키마는 원소 하나의 모양을 넘긴다 */
  isArray?: boolean;
}

/**
 * 응답 모양을 계약(packages/contract)의 zod 스키마 하나로 정한다.
 * - 실제 응답: 전역 StandardSchemaSerializerInterceptor 가 이 스키마로 검증한다 (어긋나면 500).
 * - 문서: 같은 스키마가 OpenAPI 의 응답 스키마가 된다.
 */
export function ContractResponse(
  schema: StandardSchemaV1,
  { status = HttpStatus.OK, isArray = false }: ContractResponseOptions = {},
) {
  return applyDecorators(
    HttpCode(status),
    SerializeOptions({ schema }),
    ApiResponse({ status, standardSchema: schema, isArray }),
  );
}
