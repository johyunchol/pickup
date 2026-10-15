"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { clock } from "../lib/format";
import { useMinute } from "../lib/use-minute";
import { Icon, type IconName } from "./icons";
import { useOrders } from "./orders-provider";
import styles from "./top-bar.module.css";

const TABS: { href: string; label: string; icon: IconName }[] = [
  { href: "/", label: "주문 보드", icon: "view_kanban" },
  { href: "/menu", label: "메뉴 관리", icon: "coffee" },
];

// 화면 디자인: design/pickup.pen 의 "01·02 사장님" 상단 바
export function TopBar() {
  const pathname = usePathname();
  const { orders } = useOrders();
  const now = useMinute();
  const active = orders?.filter((o) => o.status !== "done" && o.status !== "cancelled").length;

  return (
    <header className={styles.topBar}>
      <div className={styles.left}>
        <div className={styles.brand}>
          <span className={styles.mark}>
            <Icon name="local_cafe" size={20} />
          </span>
          <div>
            <div className={styles.brandName}>pickup</div>
            <div className={styles.brandSub}>온기 커피 · 카운터</div>
          </div>
        </div>
        <nav className={styles.nav}>
          {TABS.map((tab) => (
            <Link
              key={tab.href}
              href={tab.href}
              className={styles.tab}
              aria-current={pathname === tab.href ? "page" : undefined}
            >
              <Icon name={tab.icon} size={18} />
              {tab.label}
            </Link>
          ))}
        </nav>
      </div>
      <div className={styles.right}>
        <div className={styles.stat}>
          진행 중
          <span className={styles.value}>
            <span className={styles.num}>{active ?? "–"}</span>
            <span className={styles.unit}>건</span>
          </span>
        </div>
        <div className={styles.stat}>
          오늘 주문
          <span className={styles.value}>
            <span className={`${styles.num} ${styles.big}`}>{orders?.length ?? "–"}</span>
            <span className={styles.unit}>건</span>
          </span>
        </div>
        <span className={styles.divider} />
        <time className={styles.clock}>{now === null ? "" : clock(new Date(now))}</time>
      </div>
    </header>
  );
}
