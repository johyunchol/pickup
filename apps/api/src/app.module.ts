import { Module, StandardSchemaSerializerInterceptor } from "@nestjs/common";
import { APP_INTERCEPTOR, APP_PIPE } from "@nestjs/core";
import { validationPipe } from "./common/validation.pipe";
import { MenuModule } from "./menu/menu.module";
import { OrdersModule } from "./orders/orders.module";

@Module({
  imports: [MenuModule, OrdersModule],
  providers: [
    // 요청: @Body({ schema }) · @Param(name, { schema }) 의 zod 스키마로 검증하고 변환한 값을 넘긴다.
    { provide: APP_PIPE, useFactory: validationPipe },
    // 응답: @ContractResponse(schema) 의 스키마로 검증한다.
    { provide: APP_INTERCEPTOR, useClass: StandardSchemaSerializerInterceptor },
  ],
})
export class AppModule {}
