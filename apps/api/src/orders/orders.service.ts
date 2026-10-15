import { BadRequestException, ConflictException, Injectable, NotFoundException } from "@nestjs/common";
import { canCancel, lineAmount, nextStatus, type CreateOrderBody, type Order, type OrderLine } from "@pickup/contract";
import { MenuService } from "../menu/menu.service";

/** 서버 시간대 기준 날짜 — 주문 번호는 이 값이 바뀌면 1부터 다시 센다. */
function dayKey(date: Date): string {
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
}

@Injectable()
export class OrdersService {
  // 메모리 저장 — 서버를 다시 켜면 사라진다.
  private readonly orders: Order[] = [];
  private lastId = 0;
  private counter = { day: "", number: 0 };

  constructor(private readonly menuService: MenuService) {}

  findToday(now = new Date()): Order[] {
    const today = dayKey(now);
    return this.orders.filter((o) => dayKey(new Date(o.history[0].at)) === today);
  }

  findOne(id: number): Order {
    const order = this.orders.find((o) => o.id === id);
    if (!order) {
      throw new NotFoundException({ statusCode: 404, code: "NOT_FOUND", message: `주문을 찾을 수 없어요 (id ${id})` });
    }
    return order;
  }

  create(input: CreateOrderBody, now = new Date()): Order {
    // 같은 메뉴·같은 샷 추가를 여러 줄로 보내도 한 줄로 합친다.
    const merged = new Map<string, { menuId: number; extraShot: number; quantity: number }>();
    for (const { menuId, extraShot, quantity } of input.items) {
      const key = `${menuId}:${extraShot}`;
      const prev = merged.get(key);
      merged.set(key, { menuId, extraShot, quantity: (prev?.quantity ?? 0) + quantity });
    }

    const lines: OrderLine[] = [...merged.values()].map(({ menuId, extraShot, quantity }) => {
      const item = this.menuService.findOne(menuId);
      if (extraShot > 0 && item.category !== "coffee") {
        throw new BadRequestException({
          statusCode: 400,
          code: "VALIDATION_FAILED",
          message: `샷 추가는 커피만 할 수 있어요: ${item.name}`,
        });
      }
      if (item.soldOut) {
        throw new ConflictException({ statusCode: 409, code: "CONFLICT", message: `품절된 메뉴가 있어요: ${item.name}` });
      }
      return { menuId, name: item.name, price: item.price, quantity, extraShot };
    });

    const today = dayKey(now);
    if (this.counter.day !== today) this.counter = { day: today, number: 0 };

    const order: Order = {
      id: ++this.lastId,
      number: ++this.counter.number,
      nickname: input.nickname,
      lines,
      total: lines.reduce((sum, l) => sum + lineAmount(l), 0),
      status: "received",
      history: [{ status: "received", at: now.toISOString() }],
    };
    this.orders.push(order);
    return order;
  }

  advance(id: number, now = new Date()): Order {
    const order = this.findOne(id);
    const next = nextStatus(order.status);
    if (!next) {
      throw new ConflictException({
        statusCode: 409,
        code: "CONFLICT",
        message: `주문 ${order.number}번은 이미 ${order.status === "cancelled" ? "취소" : "완료"}됐어요`,
      });
    }
    order.status = next;
    order.history.push({ status: next, at: now.toISOString() });
    return order;
  }

  cancel(id: number, now = new Date()): Order {
    const order = this.findOne(id);
    if (!canCancel(order.status)) {
      throw new ConflictException({
        statusCode: 409,
        code: "CONFLICT",
        message:
          order.status === "cancelled"
            ? `주문 ${order.number}번은 이미 취소됐어요`
            : `주문 ${order.number}번은 이미 만들기 시작해서 취소할 수 없어요`,
      });
    }
    order.status = "cancelled";
    order.history.push({ status: "cancelled", at: now.toISOString() });
    return order;
  }
}
