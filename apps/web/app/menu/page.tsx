import type { Metadata } from "next";
import { MenuManager } from "./menu-manager";

export const metadata: Metadata = { title: "메뉴 관리 — 픽업" };

export default function MenuPage() {
  return <MenuManager />;
}
