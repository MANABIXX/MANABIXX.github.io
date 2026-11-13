import type { AnswerLog, QuestionProgress } from "@/domain/types";

const LOG_KEY = "manabixx:v1:answer-logs";
const PROGRESS_KEY = "manabixx:v1:progress";

export interface LearningRepository {
  getLogs(): AnswerLog[];
  getProgress(): Record<string, QuestionProgress>;
  save(log: AnswerLog, progress: QuestionProgress): void;
}

export class LocalLearningRepository implements LearningRepository {
  getLogs(): AnswerLog[] {
    if (typeof window === "undefined") return [];
    try { return JSON.parse(localStorage.getItem(LOG_KEY) ?? "[]") as AnswerLog[]; }
    catch { return []; }
  }
  getProgress(): Record<string, QuestionProgress> {
    if (typeof window === "undefined") return {};
    try { return JSON.parse(localStorage.getItem(PROGRESS_KEY) ?? "{}") as Record<string, QuestionProgress>; }
    catch { return {}; }
  }
  save(log: AnswerLog, progress: QuestionProgress): void {
    if (typeof window === "undefined") return;
    const logs = this.getLogs();
    logs.push(log);
    localStorage.setItem(LOG_KEY, JSON.stringify(logs.slice(-2000)));
    const all = this.getProgress();
    all[progress.questionId] = progress;
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(all));
  }
}
