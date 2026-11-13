import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "MANABIXX — 学びを、積み上げる。",
  description: "理科・社会・英語の高校入試4択演習。苦手な問題を自動で復習。",
  manifest: "/manifest.webmanifest",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="ja"><body>{children}</body></html>;
}
