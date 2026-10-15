import type { Metadata } from "next";
import { Noto_Sans_KR } from "next/font/google";
import type { ReactNode } from "react";
import "@pickup/tokens/tokens.css";
import "./globals.css";
import { OrdersProvider } from "./orders-provider";
import { TopBar } from "./top-bar";

// 토큰의 글꼴(Noto Sans KR)을 next/font 로 내려받아 함께 배포한다 — 사장님 PC 에 글꼴이 없어도 같은 모양.
const notoSansKr = Noto_Sans_KR({
  weight: ["400", "500", "700"],
  subsets: ["latin"],
  display: "swap",
  variable: "--font-noto-sans-kr",
});

export const metadata: Metadata = {
  title: "픽업 — 사장님",
  description: "카페 픽업 주문 사장님 화면",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ko" className={notoSansKr.variable}>
      <body>
        <OrdersProvider>
          <TopBar />
          {children}
        </OrdersProvider>
      </body>
    </html>
  );
}
