"use client";

import { useSyncExternalStore } from "react";

function subscribe(onChange: () => void) {
  const id = setInterval(onChange, 1000);
  return () => clearInterval(id);
}

const currentMinute = () => Math.floor(Date.now() / 60_000) * 60_000;

/** 지금 시각(분 단위로 내림한 ms). 서버 렌더링 중에는 null — 시계는 브라우저에서만 그린다. */
export function useMinute(): number | null {
  return useSyncExternalStore(subscribe, currentMinute, () => null);
}
