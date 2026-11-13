"use client";

import { useEffect, useState, type FormEvent, type ReactNode } from "react";

const AUTH_KEY = "manabixx-shitadumi-auth-v1";
const PASS_HASH = "b9f633dc43572056c554fd73e0906140b698fab76315cdc90e5319255f0008b1";

async function matchesPassword(value: string): Promise<boolean> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  const hash = Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
  return hash === PASS_HASH;
}

export function AuthGate({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false);
  const [authenticated, setAuthenticated] = useState(false);
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    setAuthenticated(sessionStorage.getItem(AUTH_KEY) === "1");
    setReady(true);
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy) return;
    setBusy(true);
    setError("");
    try {
      if (await matchesPassword(password)) {
        sessionStorage.setItem(AUTH_KEY, "1");
        setAuthenticated(true);
        setPassword("");
      } else {
        setError("パスワードが一致しません。もう一度確認してください。");
      }
    } catch {
      setError("認証処理に失敗しました。このブラウザで再度お試しください。");
    } finally {
      setBusy(false);
    }
  }

  if (!ready) return <main className="min-h-screen bg-black" aria-label="認証状態を確認中" />;
  if (!authenticated) return (
    <main className="lock-screen">
      <form className="lock-card" onSubmit={submit}>
        <p className="eyebrow">PERSONAL LEARNING SPACE</p>
        <h1>下積みモード</h1>
        <p className="mt-2 text-sm text-zinc-400">今日の一問から、着実に積み上げよう。</p>
        <label htmlFor="workspace-password" className="mt-7 block text-xs font-bold text-zinc-300">パスワード</label>
        <input id="workspace-password" autoComplete="current-password" type="password" value={password} onChange={(event) => setPassword(event.target.value)} className="mt-2 w-full rounded-xl border border-zinc-700 bg-zinc-950 px-4 py-3 text-white outline-none focus:border-pink-500" required />
        {error && <p role="alert" className="mt-3 text-sm text-rose-400">{error}</p>}
        <button disabled={busy} className="mt-5 w-full rounded-xl bg-pink-600 px-4 py-3 font-bold text-white transition hover:bg-pink-500 disabled:opacity-50">{busy ? "確認中…" : "ロックを解除する →"}</button>
        <p className="mt-4 text-center text-[10px] leading-5 text-zinc-600">個人利用向けの簡易ロックです。機密情報の保護を保証するものではありません。</p>
      </form>
    </main>
  );

  return <><div className="fixed right-4 top-3 z-50"><button onClick={() => { sessionStorage.removeItem(AUTH_KEY); setAuthenticated(false); }} className="rounded-full border border-zinc-700 bg-zinc-950/90 px-3 py-2 text-[11px] font-bold text-zinc-300 hover:border-pink-500 hover:text-pink-300">ログアウト</button></div>{children}</>;
}
