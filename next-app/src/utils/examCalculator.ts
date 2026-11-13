import type { ExamDefinition } from "@/constants/examDates";

const DAY_MS = 24 * 60 * 60 * 1000;

export function localDateTime(date: string): Date {
  const [year, month, day] = date.split("-").map(Number);
  return new Date(year, month - 1, day, 0, 0, 0, 0);
}

export function calculateExam(exam: ExamDefinition, now: Date) {
  const target = localDateTime(exam.date);
  const diff = target.getTime() - now.getTime();
  const passed = diff <= 0;
  const remainingMs = Math.max(0, diff);
  const remainingDays = Math.ceil(remainingMs / DAY_MS);
  const totalMinutes = Math.floor(remainingMs / 60000);
  const hours = Math.floor(totalMinutes / 60) % 24;
  const minutes = totalMinutes % 60;
  const start = localDateTime(exam.startDate).getTime();
  const duration = Math.max(1, target.getTime() - start);
  const elapsed = Math.min(duration, Math.max(0, now.getTime() - start));
  const elapsedPercent = Math.round((elapsed / duration) * 100);
  const urgency = (passed ? "passed" : remainingDays <= 7 ? "sprint" : remainingDays <= 30 ? "warning" : "normal") as const;
  const phase = (passed ? "passed" : remainingDays <= 14 ? "sprint" : remainingDays <= 60 ? "practice" : "foundation") as const;
  return { passed, remainingMs, remainingDays, hours, minutes, elapsedPercent, urgency, phase };
}

export function dailyTargetProgress(done: number, target: number) {
  return Math.min(100, Math.round((done / Math.max(1, target)) * 100));
}

export function localDayKey(date: Date) {
  return [date.getFullYear(), String(date.getMonth() + 1).padStart(2, "0"), String(date.getDate()).padStart(2, "0")].join("-");
}
