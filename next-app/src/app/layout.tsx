import type { Metadata } from "next";
import "./globals.css";
import { StoreHydration } from "@/components/store-hydration";
import { AuthGate } from "@/components/auth-gate";

export const metadata: Metadata = {
  title: "下積みモード — MANABIXX",
  description: "中学3年生向け5教科入試演習。入試逆算・弱点復習・学習記録。",
  manifest: "/manifest.webmanifest",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="ja"><body><StoreHydration><AuthGate>{children}</AuthGate></StoreHydration></body></html>;
}
