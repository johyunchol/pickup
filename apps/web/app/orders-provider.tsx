"use client";

import type { Order } from "@pickup/contract";
import { createContext, use, type ReactNode } from "react";
import { api } from "../lib/api";
import { usePolling } from "../lib/use-polling";

interface OrdersState {
  orders: Order[] | undefined;
  error: Error | undefined;
  refresh: () => void;
}

const OrdersContext = createContext<OrdersState | null>(null);

const loadOrders = () => api.orders.list();

/** 오늘 주문을 3초마다 불러와 상단 바·주문 보드·메뉴 관리가 같이 쓴다. */
export function OrdersProvider({ children }: { children: ReactNode }) {
  const { data, error, refresh } = usePolling(loadOrders);
  return <OrdersContext value={{ orders: data, error, refresh }}>{children}</OrdersContext>;
}

export function useOrders(): OrdersState {
  const state = use(OrdersContext);
  if (!state) throw new Error("OrdersProvider 안에서만 쓸 수 있어요");
  return state;
}
