import type { MenuCategory, Order, OrderStatus } from "@pickup/contract";

export const won = (n: number) => `${n.toLocaleString("ko-KR")}원`;

/** 42 → "042" */
export const orderNo = (n: number) => String(n).padStart(3, "0");

const pad2 = (n: number) => String(n).padStart(2, "0");

/** 14:32 */
export const hhmm = (d: Date) => `${pad2(d.getHours())}:${pad2(d.getMinutes())}`;

/** 10월 15일 (수) 14:32 */
export const clock = (d: Date) =>
  `${d.getMonth() + 1}월 ${d.getDate()}일 (${"일월화수목금토"[d.getDay()]}) ${hhmm(d)}`;

export const STATUS_LABEL: Record<OrderStatus, string> = {
  received: "접수",
  making: "제조 중",
  ready: "픽업 대기",
  done: "완료",
  cancelled: "취소",
};

export const CATEGORY_LABEL: Record<MenuCategory, string> = {
  coffee: "커피",
  non_coffee: "논커피",
  dessert: "디저트",
};

/** 상태가 그 단계로 바뀐 시각 */
export function statusAt(order: Order, status: OrderStatus): Date | undefined {
  const at = order.history.find((h) => h.status === status)?.at;
  return at ? new Date(at) : undefined;
}

export const orderedAt = (order: Order) => new Date(order.history[0].at);
