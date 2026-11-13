"use client";

import { useEffect } from "react";
import { useLearningStore } from "@/stores/learning-store";

export function StoreHydration({ children }: Readonly<{ children: React.ReactNode }>) {
  useEffect(() => {
    void useLearningStore.persist.rehydrate();
  }, []);
  return children;
}
