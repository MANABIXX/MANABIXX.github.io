import { Suspense } from "react";
import PracticeClient from "./practice-client";

export default function PracticePage() {
  return <Suspense fallback={<main className="shell py-16 text-center text-slate-500">演習を準備しています…</main>}><PracticeClient /></Suspense>;
}
