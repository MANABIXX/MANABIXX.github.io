"use client";

import { create } from "zustand";
import {
  createJSONStorage,
  persist,
  type StateStorage,
} from "zustand/middleware";
import type { AnswerLog, QuestionProgress } from "@/domain/types";
import { normalizeProgress, updateProgress } from "@/domain/review";
import { getJstDateKey, normalizeActiveDates } from "@/domain/study-stats";

interface LearningState {
  logs: AnswerLog[];
  progress: Record<string, QuestionProgress>;
  activeDates: string[];
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

function datesFromLogs(logs: AnswerLog[]): string[] {
  const dates: string[] = [];
  for (const log of logs) {
    try {
      dates.push(getJstDateKey(log.answeredAt));
    } catch {
      // Ignore timestamps outside the JavaScript Date range.
    }
  }
  return dates;
}

function mergeActiveDates(value: unknown, logs: AnswerLog[]): string[] {
  const persistedDates = Array.isArray(value) ? value : [];
  return normalizeActiveDates([...persistedDates, ...datesFromLogs(logs)]);
}

function normalizeStoredProgress(value: unknown, logs: AnswerLog[]): Record<string, QuestionProgress> {
  const rawProgress = isRecord(value)
    ? value as Record<string, QuestionProgress>
    : {};
  return normalizeProgress(rawProgress, logs);
}

export const useLearningStore = create<LearningState>()(
  persist(
    (set, get) => ({
      logs: [],
      progress: {},
      activeDates: [],
      record: (log) => {
        const previous = get().progress[log.questionId];
        const next = updateProgress(previous, log);
        let answeredDate: string | null = null;

        try {
          answeredDate = getJstDateKey(log.answeredAt);
        } catch {
          // The answer remains in the current session even if its timestamp is invalid.
        }

        set((state) => ({
          logs: [...state.logs, log].slice(-2000),
          activeDates: answeredDate
            ? normalizeActiveDates([...state.activeDates, answeredDate])
            : state.activeDates,
          progress: { ...state.progress, [log.questionId]: next },
        }));
      },
      reset: () => set({ logs: [], progress: {}, activeDates: [] }),
    }),
    {
      name: "manabixx-learning-v1",
      version: 3,
      storage: createJSONStorage(() => safeLocalStorage),
      skipHydration: true,
      migrate: (persistedState) => {
        if (!isRecord(persistedState)) {
          return { logs: [], progress: {}, activeDates: [] };
        }

        const logs = normalizeLogs(persistedState.logs);
        return {
          logs,
          progress: normalizeStoredProgress(persistedState.progress, logs),
          // Backfill dates from the old answer log so existing streak history survives.
          activeDates: mergeActiveDates(persistedState.activeDates, logs),
        };
      },
      merge: (persistedState, currentState) => {
        if (!isRecord(persistedState)) return currentState;

        const logs = normalizeLogs(persistedState.logs);
        return {
          ...currentState,
          logs,
          progress: normalizeStoredProgress(
            persistedState.progress ?? currentState.progress,
            logs,
          ),
          // Also repair already-versioned payloads with a missing or malformed date list.
          activeDates: mergeActiveDates(persistedState.activeDates, logs),
        };
      },
    },
  ),
);
