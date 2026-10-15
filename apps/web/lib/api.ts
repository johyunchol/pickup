import { MenuItem, Order, type UpdateMenuItemBody } from "@pickup/contract";

// 계약(packages/contract)의 zod 스키마로 응답을 parse 하는 fetch 래퍼 — 응답 타입을 따로 적지 않는다.
// 브라우저 전용: /api 는 next.config.ts 의 rewrites 로 api 서버에 닿는다.

/** api 가 2xx 가 아닌 응답을 돌려줬을 때 — 본문은 { statusCode, code, message } */
export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string | undefined,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

interface Schema<T> {
  parse(data: unknown): T;
}

async function request<T>(schema: Schema<T>, method: string, path: string, body?: unknown): Promise<T> {
  const res = await fetch(`/api${path}`, {
    method,
    headers: body === undefined ? undefined : { "content-type": "application/json" },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const data: unknown = await res.json().catch(() => undefined);
  if (!res.ok) {
    const err = (data ?? {}) as { code?: string; message?: string };
    throw new ApiError(res.status, err.code, err.message ?? `${res.status} ${res.statusText}`);
  }
  return schema.parse(data);
}

export const api = {
  menu: {
    list: () => request(MenuItem.array(), "GET", "/menu"),
    update: (id: number, body: UpdateMenuItemBody) => request(MenuItem, "PATCH", `/menu/${id}`, body),
  },
  orders: {
    list: () => request(Order.array(), "GET", "/orders"),
    advance: (id: number) => request(Order, "POST", `/orders/${id}/advance`),
  },
};
