import type { AnswerLog, MasteryLevel, QuestionProgress } from "./types";

const DAY_MS = 86_400_000;
const MIN_INTERVAL_DAYS = 1 / 24;
const MAX_INTERVAL_DAYS = 180;

const finiteNonNegative = (value: unknown, fallback = 0): number =>
  typeof value === "number" && Number.isFinite(value) && value >= 0 ? value : fallback;

const isMasteryLevel = (value: unknown): value is MasteryLevel =>
  value === "unlearned" || value === "weak" || value === "learning" || value === "mastered";

export function updateProgress(
  previous: QuestionProgress | undefined,
  log: AnswerLog,
): QuestionProgress {
  const answeredAt = finiteNonNegative(log.answeredAt, Date.now());
  const responseTimeMs = finiteNonNegative(log.responseTimeMs);
  const correct = log.isCorrect;
  const old: QuestionProgress = previous ?? {
    questionId: log.questionId,
    mastery: "unlearned",
    intervalDays: 0,
    repetition: 0,
    easeFactor: 2.5,
    nextReviewAt: 0,
    correctCount: 0,
    incorrectCount: 0,
    lastAnsweredAt: 0,
  };

  const oldRepetition = Math.floor(finiteNonNegative(old.repetition));
  const oldEaseFactor = Math.max(1.3, Math.min(2.8, finiteNonNegative(old.easeFactor, 2.5)));
  const oldIntervalDays = finiteNonNegative(old.intervalDays);
  const quickCorrect = correct && responseTimeMs <= 12_000;
  const repetition = quickCorrect ? oldRepetition + 1 : 0;
  const easeFactor = Math.max(1.3, Math.min(2.8, oldEaseFactor + (quickCorrect ? 0.1 : -0.2)));
  const rawInterval = !quickCorrect
    ? MIN_INTERVAL_DAYS
    : repetition === 1
      ? 1
      : repetition === 2
        ? 3
        : Math.max(4, oldIntervalDays * easeFactor);
  const intervalDays = Math.min(MAX_INTERVAL_DAYS, rawInterval);
  const mastery: MasteryLevel = !correct
    ? "weak"
    : repetition >= 4
      ? "mastered"
      : "learning";

  return {
    questionId: log.questionId,
    mastery,
    intervalDays,
    repetition,
    easeFactor,
    nextReviewAt: answeredAt + intervalDays * DAY_MS,
    correctCount: finiteNonNegative(old.correctCount) + (correct ? 1 : 0),
    incorrectCount: finiteNonNegative(old.incorrectCount) + (correct ? 0 : 1),
    lastAnsweredAt: answeredAt,
  };
}

function reviewScore(progress: QuestionProgress | undefined, now: number): number {
  if (!progress) return 10;
  const daysSinceAnswer = progress.lastAnsweredAt > 0
    ? Math.max(0, now - progress.lastAnsweredAt) / DAY_MS
    : 0;
  const daysOverdue = progress.nextReviewAt > 0
    ? Math.max(0, now - progress.nextReviewAt) / DAY_MS
    : 0;
  const attempts = progress.correctCount + progress.incorrectCount;
  const errorRate = attempts > 0 ? progress.incorrectCount / attempts : 0;
  const weakBoost = progress.mastery === "weak" ? 100 : 0;
  const unlearnedBoost = progress.mastery === "unlearned" ? 20 : 0;
  const dueBoost = progress.nextReviewAt > 0 && progress.nextReviewAt <= now ? 35 : 0;
  const forgettingBoost = Math.min(30, daysSinceAnswer * 1.5);
  const errorBoost = errorRate * 25;

  return weakBoost + unlearnedBoost + dueBoost + daysOverdue * 4 +
    forgettingBoost + errorBoost - progress.correctCount * 0.25;
}

export function rankForReview<T extends { id: string }>(
  items: readonly T[],
  progress: Readonly<Record<string, QuestionProgress>>,
  now = Date.now(),
): T[] {
  return items
    .map((item, index) => ({
      item,
      index,
      score: reviewScore(progress[item.id], now),
    }))
    .sort((a, b) => b.score - a.score || a.index - b.index)
    .map(({ item }) => item);
}

/** Upgrade older progress records and safely repair malformed numeric fields. */
export function normalizeProgress(
  progress: Readonly<Record<string, QuestionProgress>>,
  logs: readonly AnswerLog[],
): Record<string, QuestionProgress> {
  const latestById = new Map<string, number>();
  for (const log of logs) {
    const previous = latestById.get(log.questionId) ?? 0;
    const timestamp = finiteNonNegative(log.answeredAt);
    if (timestamp > previous) latestById.set(log.questionId, timestamp);
  }

  return Object.fromEntries(
    Object.entries(progress).map(([id, raw]) => {
      const item = raw && typeof raw === "object" ? raw : {} as QuestionProgress;
      const correctCount = finiteNonNegative(item.correctCount);
      const incorrectCount = finiteNonNegative(item.incorrectCount);
      const lastAnsweredAt = finiteNonNegative(item.lastAnsweredAt, latestById.get(id) ?? 0);
      const repaired: QuestionProgress = {
        questionId: id,
        mastery: isMasteryLevel(item.mastery) ? item.mastery : "unlearned",
        intervalDays: Math.min(MAX_INTERVAL_DAYS, finiteNonNegative(item.intervalDays)),
        repetition: Math.floor(finiteNonNegative(item.repetition)),
        easeFactor: Math.max(1.3, Math.min(2.8, finiteNonNegative(item.easeFactor, 2.5))),
        nextReviewAt: finiteNonNegative(item.nextReviewAt),
        correctCount,
        incorrectCount,
        lastAnsweredAt,
      };
      return [id, repaired];
    }),
  );
}
