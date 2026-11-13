"use client";

import { create } from "zustand";
import {
  createJSONStorage,
  persist,
  type StateStorage,
} from "zustand/middleware";
import type { AnswerLog, QuestionProgress } from "@/domain/types";
import { normalizeProgress, updateProgress } from "@/domain/review";

interface LearningState {
  logs: AnswerLog[];
  progress: Record<string, QuestionProgress>;
  record: (log: AnswerLog) => void;
  reset: () => void;
}

const safeLocalStorage: StateStorage = {
  getItem: (name) => {
    try {
      return typeof window === "undefined" ? null : window.localStorage.getItem(name);
    } catch {
      return null;
    }
  },
  setItem: (name, value) => {
    try {
      if (typeof window !== "undefined") window.localStorage.setItem(name, value);
    } catch {
      // Storage may be disabled or full. The current session remains usable.
    }
  },
  removeItem: (name) => {
    try {
      if (typeof window !== "undefined") window.localStorage.removeItem(name);
    } catch {
      // Ignore unavailable storage; do not break the learning UI.
    }
  },
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function normalizeLogs(value: unknown): AnswerLog[] {
  if (!Array.isArray(value)) return [];
  return value.filter((item): item is AnswerLog => {
    if (!isRecord(item)) return false;
    return typeof item.questionId === "string" &&
      typeof item.selectedIndex === "number" &&
      Number.isInteger(item.selectedIndex) &&
      item.selectedIndex >= 0 && item.selectedIndex <= 3 &&
      typeof item.isCorrect === "boolean" &&
      typeof item.responseTimeMs === "number" &&
      Number.isFinite(item.responseTimeMs) && item.responseTimeMs >= 0 &&
      typeof item.answeredAt === "number" &&
      Number.isFinite(item.answeredAt) && item.answeredAt >= 0;
  }).slice(-2000);
}

export const useLearningStore = create<LearningState>()(
  persist(
    (set, get) => ({
      logs: [],
      progress: {},
      record: (log) => {
        const previous = get().progress[log.questionId];
        const next = updateProgress(previous, log);
        set((state) => ({
          logs: [...state.logs, log].slice(-2000),
          progress: { ...state.progress, [log.questionId]: next },
        }));
      },
      reset: () => set({ logs: [], progress: {} }),
    }),
    {
      name: "manabixx-learning-v2",
      version: 2,
      storage: createJSONStorage(() => safeLocalStorage),
      skipHydration: true,
      migrate: (persistedState) => {
        if (!isRecord(persistedState)) return { logs: [], progress: {} };
        const logs = normalizeLogs(persistedState.logs);
        const rawProgress = isRecord(persistedState.progress)
          ? persistedState.progress as Record<string, QuestionProgress>
          : {};
        return {
          logs,
          progress: normalizeProgress(rawProgress, logs),
        };
      },
      merge: (persistedState, currentState) => {
        if (!isRecord(persistedState)) return currentState;
        const logs = normalizeLogs(persistedState.logs);
        const rawProgress = isRecord(persistedState.progress)
          ? persistedState.progress as Record<string, QuestionProgress>
          : currentState.progress;
        return {
          ...currentState,
          logs,
          progress: normalizeProgress(rawProgress, logs),
        };
      },
    },
  ),
);
