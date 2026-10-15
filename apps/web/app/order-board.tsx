"use client";

import type { Order, OrderStatus } from "@pickup/contract";
import { useState, type CSSProperties } from "react";
import { api } from "../lib/api";
import { STATUS_LABEL, hhmm, orderNo, orderedAt, statusAt } from "../lib/format";
import { useMinute } from "../lib/use-minute";
import { Icon } from "./icons";
import styles from "./order-board.module.css";
import { useOrders } from "./orders-provider";

/** 열마다 다음 단계로 넘기는 버튼 이름 — 완료·취소 열에는 버튼이 없다. */
const COLUMNS: { status: OrderStatus; action?: string }[] = [
  { status: "received", action: "제조 시작" },
  { status: "making", action: "픽업 준비 완료" },
  { status: "ready", action: "픽업 완료" },
  { status: "done" },
  { status: "cancelled" },
];

/** 끝난 주문(완료·취소)의 버튼 자리에 보이는 말 */
const CLOSED_LABEL = { done: "픽업 완료됨", cancelled: "손님이 취소함" } as const;

/** 이 시간(분)이 지나도록 끝나지 않은 주문은 경과 시간을 빨갛게 */
const LATE_MINUTES = 10;

// 화면 디자인: design/pickup.pen 의 "01 사장님 · 주문 보드"
export function OrderBoard() {
  const { orders, error, refresh } = useOrders();
  const [busyId, setBusyId] = useState<number>();
  const [actionError, setActionError] = useState<string>();

  async function advance(order: Order) {
    setBusyId(order.id);
    setActionError(undefined);
    try {
      await api.orders.advance(order.id);
    } catch (e) {
      setActionError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusyId(undefined);
      refresh();
    }
  }

  return (
    <main className={styles.board}>
      {(error ?? actionError) && (
        <p className={styles.alert} role="alert">
          {actionError ?? "주문을 불러오지 못했어요. api 서버가 켜져 있는지 확인해 주세요."}
        </p>
      )}
      {COLUMNS.map(({ status, action }) => {
        const list = (orders ?? []).filter((o) => o.status === status);
        // 진행 중인 열은 먼저 들어온 주문부터, 완료·취소 열은 방금 끝난 주문부터
        if (status === "done" || status === "cancelled") list.reverse();
        return (
          <section
            key={status}
            className={styles.column}
            style={{ "--status": `var(--color-status-${status})`, "--status-soft": `var(--color-status-${status}-soft)` } as CSSProperties}
          >
            <header className={styles.columnHeader}>
              <h2 className={styles.columnTitle}>
                <span className={styles.dot} />
                {STATUS_LABEL[status]}
              </h2>
              <span className={styles.count}>{list.length}</span>
            </header>
            <div className={styles.cards}>
              {list.length === 0 && <p className={styles.empty}>주문이 없어요</p>}
              {list.map((order) => (
                <OrderCard
                  key={order.id}
                  order={order}
                  action={action}
                  busy={busyId === order.id}
                  onAdvance={() => advance(order)}
                />
              ))}
            </div>
          </section>
        );
      })}
    </main>
  );
}

function OrderCard({
  order,
  action,
  busy,
  onAdvance,
}: {
  order: Order;
  action?: string;
  busy: boolean;
  onAdvance: () => void;
}) {
  const now = useMinute();
  const closed = order.status === "done" || order.status === "cancelled" ? order.status : undefined;
  const closedAt = closed && statusAt(order, closed);
  const minutes = now === null ? null : Math.max(0, Math.floor((now - orderedAt(order).getTime()) / 60_000));
  const late = !closed && minutes !== null && minutes >= LATE_MINUTES;

  return (
    <article className={`${styles.card} ${closed ? styles.done : ""} ${closed === "cancelled" ? styles.cancelled : ""}`}>
      <div className={styles.top}>
        <div className={styles.who}>
          <span className={styles.number}>#{orderNo(order.number)}</span>
          <span className={styles.nickname}>{order.nickname} 님</span>
        </div>
        <span className={`${styles.elapsed} ${late ? styles.late : ""}`}>
          <Icon name={closed === "cancelled" ? "cancel" : closed ? "check_circle" : "schedule"} size={14} />
          {closedAt ? hhmm(closedAt) : minutes === null ? "" : minutes === 0 ? "방금" : `${minutes}분 전`}
        </span>
      </div>
      {/* 취소된 주문은 무엇이 빠졌는지 알 수 있게 줄을 그어 남긴다. */}
      {closed !== "done" && (
        <ul className={styles.items}>
          {order.lines.map((line) => (
            // 같은 메뉴도 샷 추가가 다르면 다른 줄이다.
            <li key={`${line.menuId}-${line.extraShot}`}>
              <span className={styles.name}>
                {line.name}
                {line.extraShot > 0 && <span className={styles.shot}>샷 +{line.extraShot}</span>}
              </span>
              <span className={styles.qty}>× {line.quantity}</span>
            </li>
          ))}
        </ul>
      )}
      {action ? (
        <button type="button" className={styles.action} onClick={onAdvance} disabled={busy}>
          {action}
          <Icon name="arrow_forward" size={16} />
        </button>
      ) : (
        closed && (
          <button type="button" className={styles.action} disabled>
            {CLOSED_LABEL[closed]}
            <Icon name={closed === "cancelled" ? "close" : "check"} size={16} />
          </button>
        )
      )}
    </article>
  );
}
