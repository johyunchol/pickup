import { connection } from "next/server";

interface MenuItem {
  id: number;
  name: string;
  price: number;
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
    <main>
      <h1>메뉴</h1>
      <ul>
        {menu.map((item) => (
          <li key={item.id}>
            {item.name} — {item.price.toLocaleString("ko-KR")}원
          </li>
        ))}
      </ul>
    </main>
  );
}
