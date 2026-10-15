import { connection } from "next/server";
import styles from "./page.module.css";

interface MenuItem {
  id: number;
  name: string;
  price: number;
}

// Material Symbols 의 local_cafe — 디자인(design/pickup.pen)과 같은 아이콘
function CupIcon({ size }: { size: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2c1.11 0 2-.89 2-2V5c0-1.11-.89-2-2-2zm0 5h-2V5h2v3zM4 19h16v2H4z" />
    </svg>
  );
}

const API_URL = process.env.API_URL ?? "http://localhost:4000";

async function getMenu(): Promise<MenuItem[]> {
  const res = await fetch(`${API_URL}/menu`, { cache: "no-store" });
  if (!res.ok) {
    throw new Error(`메뉴를 불러오지 못했습니다 (${res.status})`);
  }
  return res.json();
}

export default async function Home() {
  // 요청 시점에 렌더링한다 — 빌드할 때 api 가 떠 있지 않아도 된다.
  await connection();
  const menu = await getMenu();

  return (
    <>
      <header className={styles.topBar}>
        <div className={styles.brand}>
          <span className={styles.mark}>
            <CupIcon size={20} />
          </span>
          <div>
            <div className={styles.brandName}>pickup</div>
            <div className={styles.brandSub}>사장님 화면</div>
          </div>
        </div>
      </header>
      <main className={styles.body}>
        <div>
          <h1 className={styles.title}>메뉴</h1>
          <p className={styles.desc}>지금 손님 앱에 보이는 메뉴예요.</p>
        </div>
        <ul className={styles.grid}>
          {menu.map((item) => (
            <li key={item.id} className={styles.card}>
              <span className={styles.thumb}>
                <CupIcon size={40} />
              </span>
              <div>
                <div className={styles.name}>{item.name}</div>
                <div className={styles.price}>
                  {item.price.toLocaleString("ko-KR")}원
                </div>
              </div>
            </li>
          ))}
        </ul>
      </main>
    </>
  );
}
