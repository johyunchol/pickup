// 서버 코드 → openapi/openapi.json
// `node dist/generate-openapi.js`         파일을 다시 쓴다.
// `node dist/generate-openapi.js --check` 다시 쓰지 않고, 작업본과 다르면 실패한다.
// 앱은 init 만 한다 — 포트를 열지 않는다.
import { NestFactory } from "@nestjs/core";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { AppModule } from "./app.module";
import { createOpenApiDocument } from "./openapi";

const rootDir = join(__dirname, "../../..");
const outFile = join(rootDir, "openapi/openapi.json");

/** 키를 정렬해 결과가 늘 같게 — 데코레이터 순서가 바뀌어도 diff 가 생기지 않는다. */
function sortKeys(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sortKeys);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, sortKeys((value as Record<string, unknown>)[key])]),
    );
  }
  return value;
}

async function main() {
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.init();
  const content = JSON.stringify(sortKeys(createOpenApiDocument(app)), null, 2) + "\n";
  await app.close();

  const rel = relative(rootDir, outFile);
  if (process.argv.includes("--check")) {
    const current = existsSync(outFile) ? readFileSync(outFile, "utf8") : null;
    if (current !== content) {
      console.error(`✘ ${rel} 가 서버 코드와 다릅니다`);
      console.error("pnpm api:generate 로 다시 만드세요.");
      process.exit(1);
    }
    console.log(`✔ ${rel}`);
  } else {
    mkdirSync(dirname(outFile), { recursive: true });
    writeFileSync(outFile, content);
    console.log(`▶ ${rel}`);
  }
}

void main();
