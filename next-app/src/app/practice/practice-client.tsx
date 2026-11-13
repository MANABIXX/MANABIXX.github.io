"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { AnimatePresence, motion } from "framer-motion";
import Link from "next/link";
import { questions } from "@/data/questions";
import type { Question, Subject } from "@/domain/types";
import { rankForReview } from "@/domain/review";
import { useLearningStore } from "@/stores/learning-store";

const subjectNames: Record<Subject, string> = { english: "英語", math: "数学", japanese: "国語", science: "理科", social: "社会" };
const isSubject = (value: string | null): value is Subject => value !== null && Object.hasOwn(subjectNames, value);

export default function PracticeClient() {
  const params = useSearchParams();
  const subjectParam = params.get("subject");
  const subject = isSubject(subjectParam) ? subjectParam : null;
  const reviewOnly = params.get("review") === "1";
  const progress = useLearningStore((s) => s.progress);
  const record = useLearningStore((s) => s.record);
  const [unit, setUnit] = useState("all");
  const pool = useMemo(() => {
    const filtered = questions.filter((q) => reviewOnly
      ? progress[q.id]?.mastery === "weak"
      : !subject || q.subject === subject);
    const byUnit = unit === "all" ? filtered : filtered.filter((q) => q.unit === unit);
    return rankForReview(byUnit, progress);
  }, [subject, reviewOnly, progress, unit]);
  const availableUnits = useMemo(() => [...new Set(questions
    .filter((q) => reviewOnly ? progress[q.id]?.mastery === "weak" : !subject || q.subject === subject)
    .map((q) => q.unit))], [subject, reviewOnly, progress]);
  const [index, setIndex] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [startedAt, setStartedAt] = useState(() => Date.now());
  const [finished, setFinished] = useState(false);
  const question = pool[index] as Question | undefined;

  const answer = useCallback((choice: number) => {
    if (!question || selected !== null || choice < 0 || choice > 3) return;
    const isCorrect = choice === question.correctIndex;
    record({ questionId: question.id, selectedIndex: choice, isCorrect, responseTimeMs: Math.max(0, Date.now() - startedAt), answeredAt: Date.now() });
    setSelected(choice);
  }, [question, selected, record, startedAt]);

  const next = useCallback(() => {
    if (selected === null) return;
    if (index + 1 >= pool.length) setFinished(true);
    else { setIndex((v) => v + 1); setSelected(null); setStartedAt(Date.now()); }
  }, [selected, index, pool.length]);

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      const target = event.target;
      if (target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement || target instanceof HTMLSelectElement) return;
      if (event.altKey || event.ctrlKey || event.metaKey) return;
      if (event.key >= "1" && event.key <= "4" && selected === null) answer(Number(event.key) - 1);
      if ((event.key === "Enter" || event.key === " ") && selected !== null) { event.preventDefault(); next(); }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [answer, next, selected]);

  if (finished || !question) return (
    <main className="shell flex min-h-screen items-center justify-center py-10">
      <div className="panel w-full max-w-lg p-8 text-center">
        <div className="text-5xl">🎉</div><p className="mt-5 text-sm font-bold tracking-widest text-emerald-300">SESSION COMPLETE</p>
        <h1 className="mt-2 text-3xl font-black">演習おつかれさま！</h1>
        <p className="mt-3 text-zinc-400">{pool.length === 0 && reviewOnly ? "今のところ復習が必要な問題はありません。" : "今回の問題：" + pool.length + "問"}</p>
        <p className="mt-1 text-sm text-zinc-400">解答記録はこの端末に保存されています。</p>
        <Link href="/" className="mt-8 inline-flex rounded-xl bg-pink-600 px-6 py-3 font-bold text-white">ホームへ戻る</Link>
      </div>
    </main>
  );

  return (
    <main className="shell min-h-screen py-5 md:py-8">
      <header className="flex items-center justify-between"><Link href="/" className="font-black">← MANABIXX</Link><span className="text-sm font-bold text-zinc-400">{subjectNames[question.subject]} / {question.unit}</span></header>
      <div className="mx-auto mt-8 max-w-3xl">
        <label className="mb-3 flex flex-col gap-2 text-xs font-bold text-zinc-400">分野・単元を選択<select value={unit} onChange={(e) => { setUnit(e.target.value); setIndex(0); setSelected(null); setFinished(false); setStartedAt(Date.now()); }} className="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm font-semibold text-zinc-100"><option value="all">すべての単元</option>{availableUnits.map((name) => <option key={name} value={name}>{name}</option>)}</select></label>
        <div className="mb-3 flex justify-between text-xs font-bold text-zinc-500"><span>QUESTION {index + 1} / {pool.length}</span><span>{Math.round((index / pool.length) * 100)}%</span></div>
        <div className="h-2 overflow-hidden rounded-full bg-slate-200"><div className="h-full rounded-full bg-emerald-600 transition-all" style={{ width: `${(index / pool.length) * 100}%` }} /></div>
        <AnimatePresence mode="wait">
          <motion.section key={question.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} className="panel mt-6 p-5 md:p-9">
            <div className="flex items-center gap-2"><span className="rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-300">{question.category}</span><span className="text-xs text-zinc-500">{question.mode === "vocabulary" ? "SPEED VOCAB" : "STANDARD"}</span></div>
            <h1 className="mt-7 text-xl font-black leading-relaxed md:text-2xl">{question.prompt}</h1>
            <div className="mt-7 grid gap-3">
              {question.choices.map((choice, i) => {
                const state = selected === null ? "" : i === question.correctIndex ? "correct" : i === selected ? "wrong" : "";
                return <button key={choice} disabled={selected !== null} onClick={() => answer(i)} className={`choice ${state}`}><span className="mr-4 inline-flex size-8 items-center justify-center rounded-lg bg-slate-100 text-sm font-black">{i + 1}</span>{choice}{selected !== null && i === question.correctIndex ? <span className="float-right">✓</span> : null}</button>;
              })}
            </div>
            {selected !== null && <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="mt-6 rounded-2xl bg-zinc-950 p-5">
              <p className={`text-lg font-black ${selected === question.correctIndex ? "text-emerald-300" : "text-rose-400"}`}>{selected === question.correctIndex ? "正解！" : "おしい！ 正解は " + (question.correctIndex + 1) + " 番"}</p>
              <p className="mt-2 text-sm leading-7 text-zinc-300">{question.explanation}</p>
              {question.audioText && <button onClick={() => { if ("speechSynthesis" in window) window.speechSynthesis.speak(new SpeechSynthesisUtterance(question.audioText)); }} className="mt-3 text-sm font-bold text-emerald-300">🔊 発音を聞く</button>}
              <button onClick={next} className="mt-5 w-full rounded-xl bg-pink-600 px-5 py-4 font-bold text-white">{index + 1 === pool.length ? "結果を見る" : "次の問題へ →"} <span className="ml-2 text-xs opacity-70">Enter</span></button>
            </motion.div>}
          </motion.section>
        </AnimatePresence>
        <p className="mt-4 text-center text-xs text-zinc-500">キーボード：1〜4で回答 / Enterで次へ</p>
      </div>
    </main>
  );
}
