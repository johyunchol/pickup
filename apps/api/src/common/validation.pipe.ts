import { BadRequestException, StandardSchemaValidationPipe } from "@nestjs/common";
import type { StandardSchemaV1 } from "@standard-schema/spec";

/** 요청 값이 계약과 다르면 400 — 본문은 { statusCode, code: "VALIDATION_FAILED", message } */
export function validationPipe() {
  return new StandardSchemaValidationPipe({
    exceptionFactory: (issues: readonly StandardSchemaV1.Issue[]) =>
      new BadRequestException({
        statusCode: 400,
        code: "VALIDATION_FAILED",
        message: issues.map(formatIssue).join(", "),
      }),
  });
}

function formatIssue({ path, message }: StandardSchemaV1.Issue): string {
  if (!path?.length) return message;
  const at = path.map((p) => String(typeof p === "object" ? p.key : p)).join(".");
  return `${at}: ${message}`;
}
