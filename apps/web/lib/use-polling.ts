"use client";

import { useCallback, useEffect, useState } from "react";

/** 사장님 화면의 갱신 주기 */
export const POLL_MS = 3000;

/**
 * load 를 바로 한 번, 그 뒤로 끝날 때마다 intervalMs 쉬고 다시 부른다.
 * load 는 모듈 바깥에 둔 함수처럼 매 렌더 같은 함수여야 한다.
 * refresh() 는 기다리지 않고 바로 다시 불러온다 (버튼을 누른 직후 등).
 */
export function usePolling<T>(load: () => Promise<T>, intervalMs = POLL_MS) {
  const [data, setData] = useState<T>();
  const [error, setError] = useState<Error>();
  const [round, setRound] = useState(0);

  useEffect(() => {
    let alive = true;
    let timer: ReturnType<typeof setTimeout> | undefined;
    async function run() {
      try {
        const next = await load();
        if (alive) {
          setData(next);
          setError(undefined);
        }
      } catch (e) {
        if (alive) setError(e instanceof Error ? e : new Error(String(e)));
      }
      if (alive) timer = setTimeout(run, intervalMs);
    }
    void run();
    return () => {
      alive = false;
      clearTimeout(timer);
    };
  }, [load, intervalMs, round]);

  const refresh = useCallback(() => setRound((r) => r + 1), []);
  return { data, error, refresh };
}
