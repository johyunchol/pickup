import { Body, Controller, Get, HttpStatus, Param, Post } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { CreateOrderBody, IdParam, Order } from "@pickup/contract";
import { ContractResponse } from "../common/contract-response.decorator";
import { OrdersService } from "./orders.service";

@ApiTags("orders")
@Controller("orders")
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get()
  @ApiOperation({ summary: "오늘 주문 목록 (사장님)" })
  @ContractResponse(Order, { isArray: true })
  listOrders(): Order[] {
    return this.ordersService.findToday();
  }

  @Post()
  @ApiOperation({ summary: "주문하기 (손님)" })
  @ContractResponse(Order, { status: HttpStatus.CREATED })
  createOrder(@Body({ schema: CreateOrderBody }) body: CreateOrderBody): Order {
    return this.ordersService.create(body);
  }

  @Get(":id")
  @ApiOperation({ summary: "주문 하나 (손님 — 상태 확인)" })
  @ContractResponse(Order)
  getOrder(@Param("id", { schema: IdParam }) id: number): Order {
    return this.ordersService.findOne(id);
  }

  @Post(":id/advance")
  @ApiOperation({ summary: "주문을 다음 상태로 (사장님)" })
  @ContractResponse(Order)
  advanceOrder(@Param("id", { schema: IdParam }) id: number): Order {
    return this.ordersService.advance(id);
  }
}
