"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { useLearningStore } from "@/stores/learning-store";

const subjects = [
  { id: "science", name: "理科", sub: "運動・生命・化学・地球", icon: "⚗️", color: "bg-emerald-50" },
  { id: "social", name: "社会", sub: "公民・近現代史", icon: "🌏", color: "bg-sky-50" },
  { id: "english", name: "英語", sub: "英単語・英文法", icon: "A", color: "bg-amber-50" },
] as const;

export default function Home() {
  const logs = useLearningStore((s) => s.logs);
  const progress = useLearningStore((s) => s.progress);
  const correct = logs.filter((l) => l.isCorrect).length;
  const accuracy = logs.length ? Math.round(correct / logs.length * 100) : 0;
  const weak = Object.values(progress).filter((p) => p.mastery === "weak").length;
  return (
    <main className="shell py-8 md:py-12">
      <header className="flex items-center justify-between">
        <Link href="/" className="text-xl font-black tracking-tight">MANABIXX<span className="text-emerald-600">.</span></Link>
        <span className="rounded-full border border-emerald-100 bg-white px-4 py-2 text-xs font-bold text-emerald-700">LEARNING SPACE</span>
      </header>
      <section className="mt-10 grid gap-8 md:grid-cols-[1.25fr_.75fr] md:items-end">
        <div>
          <p className="text-sm font-bold tracking-[.18em] text-emerald-700">YOUR NEXT STEP</p>
          <h1 className="mt-3 text-4xl font-black leading-tight tracking-tight md:text-5xl">今日の一問が、<br/>明日の自信になる。</h1>
          <p className="mt-4 max-w-xl text-sm leading-7 text-slate-500">理科・社会・英語を、テンポよく。間違えた問題は自動で復習リストへ。</p>
        </div>
        <div className="panel grid grid-cols-3 gap-3 p-5">
          <div><p className="text-xs text-slate-500">解答数</p><p className="mt-1 text-2xl font-black">{logs.length}</p></div>
          <div><p className="text-xs text-slate-500">正答率</p><p className="mt-1 text-2xl font-black">{accuracy}%</p></div>
          <div><p className="text-xs text-slate-500">苦手問題</p><p className="mt-1 text-2xl font-black text-rose-500">{weak}</p></div>
        </div>
      </section>
      <section className="mt-12">
        <div className="mb-5 flex items-end justify-between"><div><p className="text-xs font-bold tracking-widest text-slate-400">CHOOSE A SUBJECT</p><h2 className="mt-1 text-2xl font-black">教科を選ぶ</h2></div><span className="text-xs text-slate-400">全8問・MVP収録</span></div>
        <div className="grid gap-4 md:grid-cols-3">
          {subjects.map((subject, i) => (
            <motion.div key={subject.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * .08 }}>
              <Link href={`/practice?subject=${subject.id}`} className="subject-card panel block p-6">
                <div className={`flex size-14 items-center justify-center rounded-2xl text-2xl font-black ${subject.color}`}>{subject.icon}</div>
                <h3 className="mt-5 text-2xl font-black">{subject.name}</h3><p className="mt-2 text-sm text-slate-500">{subject.sub}</p>
                <div className="mt-7 flex items-center justify-between border-t border-slate-100 pt-4 text-sm font-bold"><span>演習をはじめる</span><span className="text-emerald-700">→</span></div>
              </Link>
            </motion.div>
          ))}
        </div>
      </section>
      <section className="mt-8 grid gap-4 md:grid-cols-2">
        <Link href="/practice?review=1" className="panel flex items-center justify-between p-5"><div><p className="text-xs font-bold tracking-widest text-rose-500">REVIEW</p><p className="mt-1 font-bold">苦手・復習問題に挑戦</p></div><span className="text-2xl">↗</span></Link>
        <div className="panel p-5"><p className="text-xs font-bold tracking-widest text-slate-400">HOW IT WORKS</p><p className="mt-1 text-sm leading-6 text-slate-600">正解・解答時間に応じて復習タイミングを調整。ログイン不要で学習記録はこの端末に保存されます。</p></div>
      </section>
      <footer className="py-10 text-center text-xs text-slate-400">MANABIXX · BUILD YOUR KNOWLEDGE</footer>
    </main>
  );
}
