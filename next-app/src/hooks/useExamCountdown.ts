"use client";

import { useEffect, useMemo, useState } from "react";
import { EXAMS, PHASE_MESSAGES } from "@/constants/examDates";
import { calculateExam, localDayKey } from "@/utils/examCalculator";
import { useLearningStore } from "@/stores/learning-store";

export function useExamCountdown() {
  const [now, setNow] = useState<Date | null>(null);
  const logs = useLearningStore((state) => state.logs);

  useEffect(() => {
    const update = () => setNow(new Date());
    update();
    const timer = window.setInterval(update, 30_000);
    return () => window.clearInterval(timer);
  }, []);

  return useMemo(() => {
    if (!now) return { ready: false as const, exams: [], todayDone: 0, streak: 0, message: "今日の一問から始めよう。" };
    const today = localDayKey(now);
    const todayDone = logs.filter((log) => localDayKey(new Date(log.answeredAt)) === today).length;
    const studiedDays = new Set(logs.map((log) => localDayKey(new Date(log.answeredAt))));
    let streak = 0;
    const cursor = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    if (!studiedDays.has(today)) cursor.setDate(cursor.getDate() - 1);
    while (studiedDays.has(localDayKey(cursor))) {
      streak += 1;
      cursor.setDate(cursor.getDate() - 1);
    }
    const exams = EXAMS.map((exam) => ({ exam, ...calculateExam(exam, now) }));
    const nearest = exams.filter((item) => !item.passed).sort((a, b) => a.remainingMs - b.remainingMs)[0];
    const phase = nearest?.phase ?? "passed";
    const messages = phase === "passed" ? ["試験を終えた自分に、お疲れ様。次の目標へ進もう。"] : PHASE_MESSAGES[phase];
    const message = streak >= 3
      ? PHASE_MESSAGES.streak[(streak + now.getDate()) % PHASE_MESSAGES.streak.length]
      : messages[(now.getDate() + now.getMonth()) % messages.length];
    return { ready: true as const, now, exams, todayDone, streak, message };
  }, [now, logs]);
}
