// 주문 api — 실제 AppModule(전역 검증 파이프·응답 직렬화)을 빈 포트에 띄워 HTTP 로 확인한다.
// `pnpm --filter @pickup/api test`
import type { INestApplication } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import type { Order } from "@pickup/contract";
import assert from "node:assert/strict";
import type { AddressInfo } from "node:net";
import { after, before, test } from "node:test";
import { AppModule } from "../app.module";

let app: INestApplication;
let base: string;

before(async () => {
  app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0);
  base = `http://localhost:${(app.getHttpServer().address() as AddressInfo).port}`;
});

after(() => app.close());

function post(path: string, body: unknown) {
  return fetch(`${base}${path}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
}

test("커피에 샷 추가 — 샷마다 500원이 줄 금액과 합계에 더해진다", async () => {
  const res = await post("/orders", {
    nickname: "도윤",
    items: [
      { menuId: 1, quantity: 2, extraShot: 1 }, // 아메리카노 (4,500 + 500) × 2
      { menuId: 2, quantity: 1, extraShot: 2 }, // 카페라떼 (5,000 + 1,000) × 1
      { menuId: 6, quantity: 1, extraShot: 0 }, // 버터 스콘 3,800
    ],
  });
  assert.equal(res.status, 201);
  const order = (await res.json()) as Order;
  assert.deepEqual(
    order.lines.map((l) => [l.name, l.price, l.quantity, l.extraShot]),
    [
      ["아메리카노", 4500, 2, 1],
      ["카페라떼", 5000, 1, 2],
      ["버터 스콘", 3800, 1, 0],
    ],
  );
  assert.equal(order.total, 10_000 + 6_000 + 3_800);
});

test("같은 메뉴도 샷 추가가 다르면 따로, 같으면 한 줄로 합친다", async () => {
  const res = await post("/orders", {
    nickname: "서연",
    items: [
      { menuId: 1, quantity: 1, extraShot: 0 },
      { menuId: 1, quantity: 1, extraShot: 1 },
      { menuId: 1, quantity: 2, extraShot: 1 },
    ],
  });
  assert.equal(res.status, 201);
  const order = (await res.json()) as Order;
  assert.deepEqual(
    order.lines.map((l) => [l.menuId, l.extraShot, l.quantity]),
    [
      [1, 0, 1],
      [1, 1, 3],
    ],
  );
  assert.equal(order.total, 4500 + 5000 * 3);
});

test("커피가 아닌 메뉴에 샷 추가가 오면 400 — 주문은 만들지 않는다", async () => {
  const beforeList = (await (await fetch(`${base}/orders`)).json()) as Order[];
  for (const menuId of [5, 6]) {
    const res = await post("/orders", { nickname: "도윤", items: [{ menuId, quantity: 1, extraShot: 1 }] });
    assert.equal(res.status, 400);
    const body = (await res.json()) as { code: string; message: string };
    assert.equal(body.code, "VALIDATION_FAILED");
    assert.match(body.message, /샷 추가는 커피만/);
  }
  const afterList = (await (await fetch(`${base}/orders`)).json()) as Order[];
  assert.equal(afterList.length, beforeList.length);
});

test("샷 추가가 없거나 0~2 밖이면 계약 검증에서 400", async () => {
  for (const item of [
    { menuId: 1, quantity: 1 },
    { menuId: 1, quantity: 1, extraShot: 3 },
    { menuId: 1, quantity: 1, extraShot: -1 },
    { menuId: 1, quantity: 1, extraShot: 1.5 },
  ]) {
    const res = await post("/orders", { nickname: "도윤", items: [item] });
    assert.equal(res.status, 400, JSON.stringify(item));
    assert.equal(((await res.json()) as { code: string }).code, "VALIDATION_FAILED");
  }
});

async function newOrder(): Promise<Order> {
  const res = await post("/orders", { nickname: "지우", items: [{ menuId: 1, quantity: 1, extraShot: 0 }] });
  assert.equal(res.status, 201);
  return (await res.json()) as Order;
}

test("접수 상태의 주문은 손님이 취소할 수 있고, 사장님 목록에도 취소로 보인다", async () => {
  const order = await newOrder();
  const res = await post(`/orders/${order.id}/cancel`, undefined);
  assert.equal(res.status, 200);
  const cancelled = (await res.json()) as Order;
  assert.equal(cancelled.status, "cancelled");
  assert.deepEqual(
    cancelled.history.map((h) => h.status),
    ["received", "cancelled"],
  );

  const list = (await (await fetch(`${base}/orders`)).json()) as Order[];
  assert.equal(list.find((o) => o.id === order.id)?.status, "cancelled");
});

test("제조가 시작된 주문은 취소할 수 없다 — 409, 상태는 그대로", async () => {
  const order = await newOrder();
  assert.equal((await post(`/orders/${order.id}/advance`, undefined)).status, 200);

  const res = await post(`/orders/${order.id}/cancel`, undefined);
  assert.equal(res.status, 409);
  const body = (await res.json()) as { code: string; message: string };
  assert.equal(body.code, "CONFLICT");
  assert.match(body.message, /만들기 시작해서 취소할 수 없어요/);

  const after = (await (await fetch(`${base}/orders/${order.id}`)).json()) as Order;
  assert.equal(after.status, "making");
});

test("취소된 주문은 다시 취소하거나 다음 단계로 넘길 수 없다", async () => {
  const order = await newOrder();
  assert.equal((await post(`/orders/${order.id}/cancel`, undefined)).status, 200);

  for (const action of ["cancel", "advance"]) {
    const res = await post(`/orders/${order.id}/${action}`, undefined);
    assert.equal(res.status, 409, action);
    assert.match(((await res.json()) as { message: string }).message, /이미 취소됐어요/);
  }
  const after = (await (await fetch(`${base}/orders/${order.id}`)).json()) as Order;
  assert.equal(after.status, "cancelled");
});

test("없는 주문을 취소하면 404", async () => {
  const res = await post("/orders/9999/cancel", undefined);
  assert.equal(res.status, 404);
});
