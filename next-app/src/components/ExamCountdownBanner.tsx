"use client";

import { useExamCountdown } from "@/hooks/useExamCountdown";
import { dailyTargetProgress } from "@/utils/examCalculator";

type Props = { compact?: boolean };

export default function ExamCountdownBanner({ compact = false }: Props) {
  const data = useExamCountdown();
  if (!data.ready) {
    return <section aria-label="入試カウントダウン" className="panel animate-pulse p-5"><div className="h-5 w-40 rounded bg-zinc-800" /><div className="mt-4 h-12 w-56 rounded bg-zinc-800" /></section>;
  }

  return (
    <section aria-label="入試カウントダウン" className="space-y-4">
      <div className="grid gap-3 md:grid-cols-2">
        {data.exams.map(({ exam, passed, remainingDays, hours, minutes, elapsedPercent, urgency }) => {
          const tone = urgency === "sprint" ? "border-rose-900 bg-rose-950/30" : urgency === "warning" ? "border-amber-900 bg-amber-950/20" : "border-zinc-800 bg-zinc-950";
          const accent = urgency === "sprint" ? "text-rose-300" : urgency === "warning" ? "text-amber-300" : "text-emerald-300";
          return (
            <article key={exam.id} className={`rounded-2xl border p-5 shadow-sm ${tone}`}>
              <div className="flex items-start justify-between gap-3">
                <div><p className="text-xs font-extrabold tracking-wide text-zinc-400">{exam.detail}</p><h3 className="mt-1 text-lg font-black text-zinc-50">{exam.name}</h3></div>
                <span className={`rounded-full bg-black/50 px-3 py-1 text-[11px] font-bold ${accent}`}>{passed ? "NEXT STAGE" : urgency === "sprint" ? "LAST SPURT" : urgency === "warning" ? "あと少し" : "COUNTDOWN"}</span>
              </div>
              {passed ? <><p className="mt-5 text-2xl font-black text-zinc-50">お疲れ様でした！</p><p className="mt-1 text-sm text-zinc-300">次の目標へ、一歩ずつ。</p></> : <>
                <div className="mt-5 flex items-end gap-2"><strong className={`text-5xl font-black tracking-tight tabular-nums ${accent}`}>{remainingDays}</strong><span className="pb-1 text-sm font-bold text-zinc-300">日</span></div>
                <p className="mt-1 text-xs font-semibold text-slate-600">あと {hours}時間 {minutes}分</p>
                <div className="mt-4 flex items-center justify-between text-[10px] font-bold text-zinc-400"><span>入試までの準備期間</span><span>{elapsedPercent}%</span></div>
                <div className="mt-2 h-2 overflow-hidden rounded-full bg-zinc-800"><div className={`h-full rounded-full transition-[width] duration-500 ${urgency === "sprint" ? "bg-rose-500" : urgency === "warning" ? "bg-amber-400" : "bg-emerald-950/400"}`} style={{ width: `${elapsedPercent}%` }} /></div>
                {exam.provisional && <p className="mt-2 text-[10px] text-slate-500">※日程は仮設定。募集要項公表後に更新してください。</p>}
              </>}
            </article>
          );
        })}
      </div>
      {!compact && <div className="panel border-zinc-800 bg-zinc-950 p-5">
        <div className="flex flex-wrap items-center justify-between gap-3"><div><p className="text-xs font-extrabold tracking-widest text-zinc-500">TODAY'S MISSION</p><p className="mt-1 text-lg font-black">今日の目標は {data.exams.find((e) => !e.passed)?.exam.dailyTarget ?? 0} 問</p><p className="mt-1 text-xs text-slate-500">入試までの計画目安：約 {((data.exams.find((e) => !e.passed)?.remainingDays ?? 0) * (data.exams.find((e) => !e.passed)?.exam.dailyTarget ?? 0)).toLocaleString("ja-JP")} 問</p></div><div className="text-right"><p className="text-2xl font-black tabular-nums">{data.todayDone}<span className="text-sm text-zinc-500"> / {data.exams.find((e) => !e.passed)?.exam.dailyTarget ?? 0}問</span></p><p className="text-xs font-bold text-emerald-300">{dailyTargetProgress(data.todayDone, data.exams.find((e) => !e.passed)?.exam.dailyTarget ?? 1)}% 達成</p></div></div>
        <div className="mt-3 h-3 overflow-hidden rounded-full bg-zinc-800"><div className="h-full rounded-full bg-pink-500 transition-[width] duration-500" style={{ width: `${dailyTargetProgress(data.todayDone, data.exams.find((e) => !e.passed)?.exam.dailyTarget ?? 1)}%` }} /></div>
        <div className="mt-4 flex flex-wrap items-center justify-between gap-2"><p className="text-sm leading-6 text-slate-600">「{data.message}」</p><span className="rounded-full bg-emerald-950/40 px-3 py-1 text-xs font-bold text-emerald-700">🔥 {data.streak}日連続</span></div>
      </div>}
    </section>
  );
}
