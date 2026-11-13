"use client";

import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import type { AnswerLog, QuestionProgress } from "@/domain/types";
import { updateProgress } from "@/domain/review";

interface LearningState {
  logs: AnswerLog[];
  progress: Record<string, QuestionProgress>;
  record: (log: AnswerLog) => void;
  reset: () => void;
}

export const useLearningStore = create<LearningState>()(persist(
  (set, get) => ({
    logs: [],
    progress: {},
    record: (log) => {
      const next = updateProgress(get().progress[log.questionId], log);
      set((state) => ({
        logs: [...state.logs, log].slice(-2000),
        progress: { ...state.progress, [log.questionId]: next },
      }));
    },
    reset: () => set({ logs: [], progress: {} }),
  }),
  { name: "manabixx-learning-v1", storage: createJSONStorage(() => localStorage) }
));
