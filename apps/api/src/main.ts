import { NestFactory } from "@nestjs/core";
import { SwaggerModule } from "@nestjs/swagger";
import { AppModule } from "./app.module";
import { createOpenApiDocument } from "./openapi";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // 개발 중 확인용 문서 화면 — 저장소의 openapi/openapi.json 과 같은 문서다.
  SwaggerModule.setup("docs", app, () => createOpenApiDocument(app));
  const port = Number(process.env.PORT ?? 4000);
  await app.listen(port);
  console.log(`api listening on http://localhost:${port}`);
}

void bootstrap();
