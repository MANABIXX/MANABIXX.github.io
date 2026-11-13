"use client";

import { useEffect, useState } from "react";
import { useLearningStore } from "@/stores/learning-store";

export function StoreHydration({ children }: Readonly<{ children: React.ReactNode }>) {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let active = true;
    Promise.resolve(useLearningStore.persist.rehydrate())
      .catch(() => undefined)
      .finally(() => {
        if (active) setReady(true);
      });
    return () => {
      active = false;
    };
  }, []);

  if (!ready) {
    return (
      <main className="shell flex min-h-screen items-center justify-center text-sm text-zinc-400" aria-live="polite">
        学習データを読み込んでいます…
      </main>
    );
  }

  return children;
}
