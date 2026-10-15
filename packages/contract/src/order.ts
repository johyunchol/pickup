import { z } from "zod";

/** 주문 상태는 이 순서로만 넘어간다. 사장님 화면에서 한 단계씩 넘긴다. */
export const ORDER_STATUSES = ["received", "making", "ready", "done"] as const;

export const OrderStatus = z
  .enum(ORDER_STATUSES)
  .meta({ id: "OrderStatus", description: "received 접수 → making 제조 중 → ready 픽업 대기 → done 완료" });
export type OrderStatus = z.infer<typeof OrderStatus>;

/** 다음 상태. 완료(done) 다음은 없다. */
export function nextStatus(status: OrderStatus): OrderStatus | undefined {
  return ORDER_STATUSES[ORDER_STATUSES.indexOf(status) + 1];
}

/** 샷 추가 한 번 값(원). 샷 추가는 커피(category "coffee")만 된다. */
export const EXTRA_SHOT_PRICE = 500;

/** 주문할 때 고른 메뉴 한 줄 — 이름·가격은 주문 시점 값으로 남긴다. price 는 샷 추가를 뺀 메뉴 가격. */
export const OrderLine = z
  .object({
    menuId: z.int().positive(),
    name: z.string(),
    price: z.int().nonnegative(),
    quantity: z.int().positive(),
    extraShot: z.int().min(0).max(2).meta({ description: "샷 추가 횟수 0~2번 · 커피 메뉴만 · 한 번에 500원" }),
  })
  .meta({ id: "OrderLine" });
export type OrderLine = z.infer<typeof OrderLine>;

/** 한 줄 금액 — (메뉴 가격 + 샷 추가) × 수량 */
export function lineAmount(line: Pick<OrderLine, "price" | "quantity" | "extraShot">): number {
  return (line.price + line.extraShot * EXTRA_SHOT_PRICE) * line.quantity;
}

export const StatusChange = z
  .object({
    status: OrderStatus,
    at: z.iso.datetime(),
  })
  .meta({ id: "StatusChange" });
export type StatusChange = z.infer<typeof StatusChange>;

export const Order = z
  .object({
    id: z.int().positive(),
    number: z.int().positive().meta({ description: "그날의 주문 번호 — 날짜가 바뀌면 1부터 다시" }),
    nickname: z.string(),
    lines: z.array(OrderLine),
    total: z.int().nonnegative(),
    status: OrderStatus,
    history: z.array(StatusChange).meta({ description: "상태가 바뀐 시각 — 첫 줄이 접수(주문) 시각" }),
  })
  .meta({ id: "Order" });
export type Order = z.infer<typeof Order>;

export const CreateOrderItem = z
  .object({
    menuId: z.int().positive(),
    quantity: z.int().min(1).max(20),
    extraShot: z.int().min(0).max(2).meta({ description: "샷 추가 횟수 0~2번 · 커피 메뉴만 · 한 번에 500원" }),
  })
  .meta({ id: "CreateOrderItem" });
export type CreateOrderItem = z.infer<typeof CreateOrderItem>;

export const CreateOrderBody = z
  .object({
    nickname: z.string().trim().min(1).max(12),
    items: z.array(CreateOrderItem).min(1).max(20),
  })
  .meta({ id: "CreateOrderBody" });
export type CreateOrderBody = z.infer<typeof CreateOrderBody>;
