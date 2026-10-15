"use client";

import type { MenuCategory, MenuItem } from "@pickup/contract";
import { useState } from "react";
import { api } from "../../lib/api";
import { CATEGORY_LABEL, won } from "../../lib/format";
import { usePolling } from "../../lib/use-polling";
import { Icon, type IconName } from "../icons";
import { useOrders } from "../orders-provider";
import styles from "./menu-manager.module.css";

const loadMenu = () => api.menu.list();

const CATEGORY_ICON: Record<MenuCategory, IconName> = {
  coffee: "local_cafe",
  non_coffee: "emoji_food_beverage",
  dessert: "bakery_dining",
};

const FILTERS: (MenuCategory | "all")[] = ["all", "coffee", "non_coffee", "dessert"];

// 화면 디자인: design/pickup.pen 의 "02 사장님 · 메뉴 관리"
export function MenuManager() {
  const { data: menu, error, refresh } = usePolling(loadMenu);
  const { orders } = useOrders();
  const [filter, setFilter] = useState<MenuCategory | "all">("all");
  const [busyId, setBusyId] = useState<number>();
  const [actionError, setActionError] = useState<string>();

  // 오늘 팔린 수량 — 오늘 주문에서 메뉴별로 더한다.
  const soldToday = new Map<number, number>();
  for (const line of (orders ?? []).flatMap((o) => o.lines)) {
    soldToday.set(line.menuId, (soldToday.get(line.menuId) ?? 0) + line.quantity);
  }

  async function toggle(item: MenuItem) {
    setBusyId(item.id);
    setActionError(undefined);
    try {
      await api.menu.update(item.id, { soldOut: !item.soldOut });
    } catch (e) {
      setActionError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusyId(undefined);
      refresh();
    }
  }

  const items = menu ?? [];
  const soldOutCount = items.filter((m) => m.soldOut).length;
  const shown = filter === "all" ? items : items.filter((m) => m.category === filter);

  return (
    <main className={styles.body}>
      <div className={styles.pageHeader}>
        <div>
          <h1 className={styles.title}>메뉴 관리</h1>
          <p className={styles.desc}>품절로 바꾸면 손님 앱에서 바로 주문할 수 없게 돼요.</p>
        </div>
        {menu && (
          <div className={styles.summary}>
            <span className={`${styles.pill} ${styles.onSale}`}>
              <span className={styles.dot} />
              판매 중 {items.length - soldOutCount}
            </span>
            <span className={`${styles.pill} ${styles.soldOutPill}`}>
              <span className={styles.dot} />
              품절 {soldOutCount}
            </span>
          </div>
        )}
      </div>

      <div className={styles.filter} role="tablist">
        {FILTERS.map((f) => (
          <button
            key={f}
            type="button"
            role="tab"
            aria-selected={filter === f}
            className={styles.chip}
            onClick={() => setFilter(f)}
          >
            {f === "all" ? "전체" : CATEGORY_LABEL[f]}{" "}
            {f === "all" ? items.length : items.filter((m) => m.category === f).length}
          </button>
        ))}
      </div>

      {(error ?? actionError) && (
        <p className={styles.alert} role="alert">
          {actionError ?? "메뉴를 불러오지 못했어요. api 서버가 켜져 있는지 확인해 주세요."}
        </p>
      )}

      <ul className={styles.grid}>
        {shown.map((item) => (
          <li key={item.id} className={`${styles.card} ${item.soldOut ? styles.soldOut : ""}`}>
            <span className={styles.thumb}>
              <Icon name={CATEGORY_ICON[item.category]} size={40} />
            </span>
            <div className={styles.info}>
              <div className={styles.nameRow}>
                <span className={styles.name}>{item.name}</span>
                {item.soldOut && <span className={styles.badge}>품절</span>}
              </div>
              <div className={styles.meta}>
                {CATEGORY_LABEL[item.category]} · 오늘 {soldToday.get(item.id) ?? 0}
                {item.category === "dessert" ? "개" : "잔"}
              </div>
              <div className={styles.price}>{won(item.price)}</div>
            </div>
            <div className={styles.switch}>
              <button
                type="button"
                role="switch"
                aria-checked={!item.soldOut}
                aria-label={`${item.name} 판매`}
                className={styles.toggle}
                disabled={busyId === item.id}
                onClick={() => toggle(item)}
              >
                <span className={styles.knob} />
              </button>
              <span className={styles.state}>{item.soldOut ? "품절" : "판매 중"}</span>
            </div>
          </li>
        ))}
      </ul>

      <p className={styles.tip}>
        <Icon name="info" size={20} />
        품절 메뉴는 손님 앱에서 회색으로 보이고 담기 버튼이 사라져요. 다시 켜면 바로 주문을 받을 수 있어요.
      </p>
    </main>
  );
}
