"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { useLearningStore } from "@/stores/learning-store";
import ExamCountdownBanner from "@/components/ExamCountdownBanner";

const subjects = [
  { id: "english", name: "英語", sub: "英単語・英文法", icon: "A", color: "bg-pink-950/40" },
  { id: "math", name: "数学", sub: "関数・図形・方程式", icon: "∑", color: "bg-pink-950/40" },
  { id: "japanese", name: "国語", sub: "文法・古文・読解", icon: "文", color: "bg-pink-950/40" },
  { id: "science", name: "理科", sub: "物理・化学・生物・地学", icon: "⚗", color: "bg-pink-950/40" },
  { id: "social", name: "社会", sub: "歴史・公民・地理", icon: "◎", color: "bg-pink-950/40" },
] as const;

export default function Home() {
  const logs = useLearningStore((s) => s.logs);
  const progress = useLearningStore((s) => s.progress);
  const correct = logs.filter((l) => l.isCorrect).length;
  const accuracy = logs.length ? Math.round(correct / logs.length * 100) : 0;
  const weak = Object.values(progress).filter((p) => p.mastery === "weak").length;
  return (
    <main className="shell py-6 md:py-10">
      <header className="flex items-center justify-between">
        <Link href="/" className="text-xl font-black tracking-tight text-white">MANABIXX<span className="text-pink-500">.</span></Link>
        <span className="rounded-full border border-zinc-800 bg-zinc-950 px-4 py-2 text-xs font-bold text-pink-300">SHITADUMI / STUDY</span>
      </header>
      <section className="mt-10 grid gap-8 md:grid-cols-[1.25fr_.75fr] md:items-end">
        <div>
          <p className="text-sm font-bold tracking-[.18em] text-pink-400">YOUR NEXT STEP</p>
          <h1 className="mt-3 text-4xl font-black leading-tight tracking-tight md:text-5xl">今日の一問が、<br/>明日の自信になる。</h1>
          <p className="mt-4 max-w-xl text-sm leading-7 text-zinc-400">5教科を毎日少しずつ。間違えた問題は復習リストへ。</p>
        </div>
        <div className="panel grid grid-cols-3 gap-3 p-5">
          <div><p className="text-xs text-zinc-400">解答数</p><p className="mt-1 text-2xl font-black">{logs.length}</p></div>
          <div><p className="text-xs text-zinc-400">正答率</p><p className="mt-1 text-2xl font-black">{accuracy}%</p></div>
          <div><p className="text-xs text-zinc-400">苦手問題</p><p className="mt-1 text-2xl font-black text-rose-400">{weak}</p></div>
        </div>
      </section>
      <section className="mt-8"><ExamCountdownBanner /></section>
      <section className="mt-12">
        <div className="mb-5 flex items-end justify-between"><div><p className="text-xs font-bold tracking-widest text-zinc-500">CHOOSE A SUBJECT</p><h2 className="mt-1 text-2xl font-black">5教科演習</h2></div><span className="text-xs text-zinc-500">サンプル問題収録</span></div>
        <div className="grid gap-4 md:grid-cols-3">
          {subjects.map((subject, i) => (
            <motion.div key={subject.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * .08 }}>
              <Link href={`/practice?subject=${subject.id}`} className="subject-card panel block p-6">
                <div className={`flex size-14 items-center justify-center rounded-2xl text-2xl font-black ${subject.color}`}>{subject.icon}</div>
                <h3 className="mt-5 text-2xl font-black">{subject.name}</h3><p className="mt-2 text-sm text-zinc-400">{subject.sub}</p>
                <div className="mt-7 flex items-center justify-between border-t border-zinc-800 pt-4 text-sm font-bold"><span>演習をはじめる</span><span className="text-pink-400">→</span></div>
              </Link>
            </motion.div>
          ))}
        </div>
      </section>
      <section className="mt-8 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Link href="/practice" className="panel flex items-center justify-between p-5"><div><p className="text-xs font-bold tracking-widest text-pink-400">ALL SUBJECTS</p><p className="mt-1 font-bold">5教科まとめて演習</p></div><span className="text-2xl text-pink-400">→</span></Link>
        <Link href="/practice?review=1" className="panel flex items-center justify-between p-5"><div><p className="text-xs font-bold tracking-widest text-rose-500">REVIEW</p><p className="mt-1 font-bold">間違えた問題だけ復習</p></div><span className="text-2xl">↗</span></Link>
        <div className="panel p-5"><p className="text-xs font-bold tracking-widest text-zinc-500">HOW IT WORKS</p><p className="mt-1 text-sm leading-6 text-zinc-400">間違い・解答時間・正答回数に応じて復習タイミングを調整。認証はタブ内で維持され、学習記録はこの端末に保存されます。</p></div>
      </section>
      <footer className="py-10 text-center text-xs text-zinc-500">MANABIXX · BUILD YOUR KNOWLEDGE</footer>
    </main>
  );
}
