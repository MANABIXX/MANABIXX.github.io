import type { AnswerLog, QuestionProgress } from "@/domain/types";

export interface StudyStats {
  streak: number;
  todayCompleted: number;
  dailyGoal: number;
  clearedWeakQuestions: number;
  goalAchieved: boolean;
  progressPercent: number;
}

const DATE_KEY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

/** Returns a stable YYYY-MM-DD key in Japan Standard Time. */
export function getJstDateKey(timestamp: number): string {
  if (!Number.isFinite(timestamp)) {
    throw new RangeError("timestamp must be a finite number");
  }

  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date(timestamp));

  const values = Object.fromEntries(
    parts.map((part) => [part.type, part.value]),
  );

  return `${values.year}-${values.month}-${values.day}`;
}

function isValidDateKey(value: string): boolean {
  if (!DATE_KEY_PATTERN.test(value)) return false;
  const date = new Date(`${value}T00:00:00.000Z`);
  return Number.isFinite(date.getTime()) &&
    date.toISOString().slice(0, 10) === value;
}

function shiftDate(dateKey: string, amount: number): string {
  const date = new Date(`${dateKey}T00:00:00.000Z`);
  date.setUTCDate(date.getUTCDate() + amount);
  return date.toISOString().slice(0, 10);
}

/** Sanitizes persisted date keys and keeps only the latest 400 calendar days. */
export function normalizeActiveDates(value: unknown): string[] {
  if (!Array.isArray(value)) return [];

  const unique = new Set<string>();
  for (const item of value) {
    if (typeof item === "string" && isValidDateKey(item)) {
      unique.add(item);
    }
  }

  return [...unique].sort().slice(-400);
}

export function getStudyStats(
  logs: AnswerLog[],
  activeDates: string[],
  progress: Record<string, QuestionProgress>,
  now: number,
  dailyGoal = 20,
): StudyStats {
  const today = getJstDateKey(now);
  const safeGoal = Number.isFinite(dailyGoal)
    ? Math.max(1, Math.floor(dailyGoal))
    : 20;

  const todayLogs = logs.filter(
    (log) => getJstDateKey(log.answeredAt) === today,
  );

  // Count distinct questions, not repeated attempts, toward the daily target.
  const completedIds = new Set(todayLogs.map((log) => log.questionId));

  // A weak question is cleared once per day when it is answered correctly after
  // having at least one recorded mistake in its lifetime history.
  const clearedIds = new Set(
    todayLogs
      .filter(
        (log) =>
          log.isCorrect &&
          (progress[log.questionId]?.incorrectCount ?? 0) > 0,
      )
      .map((log) => log.questionId),
  );

  const active = new Set(normalizeActiveDates(activeDates));
  let cursor = active.has(today) ? today : shiftDate(today, -1);
  let streak = 0;

  while (active.has(cursor)) {
    streak += 1;
    cursor = shiftDate(cursor, -1);
  }

  const todayCompleted = completedIds.size;
  const progressPercent = Math.min(
    100,
    Math.round((todayCompleted / safeGoal) * 100),
  );

  return {
    streak,
    todayCompleted,
    dailyGoal: safeGoal,
    clearedWeakQuestions: clearedIds.size,
    goalAchieved: todayCompleted >= safeGoal,
    progressPercent,
  };
}
