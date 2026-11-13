"use client";

import { useEffect, useMemo, useState } from "react";
import { motion } from "framer-motion";
import { getStudyStats } from "@/domain/study-stats";
import { useLearningStore } from "@/stores/learning-store";

const DAILY_GOAL = 20;

export function StudyDashboard() {
  const logs = useLearningStore((state) => state.logs);
  const progress = useLearningStore((state) => state.progress);
  const activeDates = useLearningStore((state) => state.activeDates);
  const [now, setNow] = useState<number | null>(null);

  useEffect(() => {
    const updateNow = () => setNow(Date.now());
    updateNow();

    const timerId = window.setInterval(updateNow, 60_000);
    return () => window.clearInterval(timerId);
  }, []);

  const stats = useMemo(() => {
    if (now === null) return null;
    return getStudyStats(logs, activeDates, progress, now, DAILY_GOAL);
  }, [logs, activeDates, progress, now]);

  if (stats === null) {
    return (
      <section className="panel p-5" aria-live="polite">
        <p className="text-sm text-zinc-400">学習データを確認しています…</p>
      </section>
    );
  }

  return (
    <section
      className="panel relative overflow-hidden p-5 md:p-6"
      aria-labelledby="study-dashboard-title"
    >
      <div className="pointer-events-none absolute -right-16 -top-20 size-56 rounded-full bg-pink-500/10 blur-3xl" />

      <div className="relative">
        <div className="mb-5 flex flex-wrap items-center justify-between gap-2">
          <div>
            <p className="text-[10px] font-black tracking-[.2em] text-pink-400">
              YOUR DAILY RECORD
            </p>
            <h2 id="study-dashboard-title" className="mt-1 text-xl font-black">
              今日の積み重ね
            </h2>
          </div>
          {stats.goalAchieved ? (
            <span className="rounded-full border border-emerald-400/30 bg-emerald-400/10 px-3 py-1.5 text-xs font-bold text-emerald-300">
              GOAL COMPLETE
            </span>
          ) : (
            <span className="rounded-full border border-zinc-700 bg-zinc-900 px-3 py-1.5 text-xs font-bold text-zinc-300">
              DAILY GOAL · {stats.dailyGoal}問
            </span>
          )}
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div className="rounded-2xl border border-zinc-800 bg-zinc-950/80 p-3 sm:p-4">
            <p className="text-[11px] font-semibold text-zinc-400">連続学習</p>
            <p className="mt-2 text-2xl font-black tabular-nums sm:text-3xl">
              {stats.streak}
              <span className="ml-1 text-xs font-bold text-zinc-500">日</span>
            </p>
            <p className="mt-1 text-[10px] text-zinc-500">STREAK</p>
          </div>

          <div className="rounded-2xl border border-zinc-800 bg-zinc-950/80 p-3 sm:p-4">
            <p className="text-[11px] font-semibold text-zinc-400">今日の演習</p>
            <p className="mt-2 text-2xl font-black tabular-nums sm:text-3xl">
              {stats.todayCompleted}
              <span className="ml-1 text-xs font-bold text-zinc-500">
                / {stats.dailyGoal}
              </span>
            </p>
            <p className="mt-1 text-[10px] text-zinc-500">QUESTIONS</p>
          </div>

          <div className="rounded-2xl border border-zinc-800 bg-zinc-950/80 p-3 sm:p-4">
            <p className="text-[11px] font-semibold text-zinc-400">苦手クリア</p>
            <p className="mt-2 text-2xl font-black tabular-nums text-emerald-300 sm:text-3xl">
              {stats.clearedWeakQuestions}
              <span className="ml-1 text-xs font-bold text-zinc-500">問</span>
            </p>
            <p className="mt-1 text-[10px] text-zinc-500">WEAK POINTS</p>
          </div>
        </div>

        <div className="mt-6">
          <div className="mb-2 flex items-center justify-between text-xs">
            <span className="font-bold tracking-wider text-zinc-300">
              DAILY PROGRESS
            </span>
            <span className="font-black tabular-nums text-pink-300">
              {stats.progressPercent}%
            </span>
          </div>
          <div
            className="h-3 overflow-hidden rounded-full bg-zinc-800"
            role="progressbar"
            aria-label="今日の学習目標達成率"
            aria-valuemin={0}
            aria-valuemax={100}
            aria-valuenow={stats.progressPercent}
          >
            <motion.div
              className="h-full rounded-full bg-gradient-to-r from-pink-600 to-fuchsia-400"
              initial={{ width: 0 }}
              animate={{ width: `${stats.progressPercent}%` }}
              transition={{ duration: 0.65, ease: "easeOut" }}
            />
          </div>
          <p className="mt-2 text-xs text-zinc-500" aria-live="polite">
            {stats.goalAchieved
              ? "今日の目標を達成！この積み重ねが実力になる。"
              : `あと${Math.max(0, stats.dailyGoal - stats.todayCompleted)}問で今日の目標達成。`}
          </p>
        </div>

        {stats.goalAchieved && (
          <motion.div
            initial={{ opacity: 0, y: 8, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 0.3 }}
            className="mt-4 rounded-xl border border-emerald-400/25 bg-emerald-400/10 p-4"
            aria-live="polite"
          >
            <p className="font-black text-emerald-300">
              TODAY&apos;S GOAL COMPLETE!
            </p>
            <p className="mt-1 text-sm leading-6 text-zinc-300">
              今日のノルマ達成。ここまで続けた自分を、ちゃんと認めよう。
            </p>
          </motion.div>
        )}
      </div>
    </section>
  );
}
