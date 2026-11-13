import type { AnswerLog, MasteryLevel, QuestionProgress } from "./types";

const DAY = 86_400_000;

export function updateProgress(previous: QuestionProgress | undefined, log: AnswerLog): QuestionProgress {
  const correct = log.isCorrect;
  const old = previous ?? {
    questionId: log.questionId, mastery: "unlearned" as MasteryLevel,
    intervalDays: 0, repetition: 0, easeFactor: 2.5, nextReviewAt: 0,
    correctCount: 0, incorrectCount: 0,
  };
  const slow = log.responseTimeMs > 12_000;
  const repetition = correct && !slow ? old.repetition + 1 : 0;
  const easeFactor = Math.max(1.3, Math.min(2.8, old.easeFactor + (correct && !slow ? 0.1 : -0.2)));
  const intervalDays = !correct || slow ? 0.04 : repetition === 1 ? 1 : repetition === 2 ? 3 : Math.round(old.intervalDays * easeFactor);
  const mastery: MasteryLevel = !correct ? "weak" : repetition >= 4 ? "mastered" : "learning";
  return {
    questionId: log.questionId, mastery, intervalDays, repetition, easeFactor,
    nextReviewAt: log.answeredAt + intervalDays * DAY,
    correctCount: old.correctCount + (correct ? 1 : 0),
    incorrectCount: old.incorrectCount + (correct ? 0 : 1),
  };
}

export function rankForReview<T extends { id: string }>(
  items: T[], progress: Record<string, QuestionProgress>, now = Date.now()
): T[] {
  return [...items].sort((a, b) => {
    const pa = progress[a.id], pb = progress[b.id];
    const score = (id: string, p: QuestionProgress | undefined): number => {
      if (!p) return 1;
      const overdue = Math.max(0, now - p.nextReviewAt) / DAY;
      return (p.mastery === "weak" ? 100 : 0) + overdue + p.incorrectCount * 3 - p.correctCount * 0.1;
    };
    return score(b.id, pb) - score(a.id, pa);
  });
}
