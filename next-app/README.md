# MANABIXX Next.js learning app

## Local development
```bash
npm install
npm run dev
```

## Vercel
Import this repository and set **Root Directory** to `next-app`.

## Exam date maintenance
Edit `src/constants/examDates.ts`. Dates are Japan local calendar dates in `YYYY-MM-DD` format. The current 2027 dates are provisional examples and must be replaced with official school / prefectural board schedules once published. The progress-bar start date can be adjusted independently.

The daily question target is 30 answers. Change the target in `src/constants/examDates.ts` (each exam's `dailyTarget`) and keep the display target in `src/components/ExamCountdownBanner.tsx` in sync.


## 下積みモード認証
- パスワードは `haru`。Next.js版は `sessionStorage` を使い、同じタブ内ではリロード・ページ移動後も認証を維持します。
- 画面右上の「ログアウト」で解除できます。
- この方式は個人利用向けの簡易ロックです。クライアント側コードを解析できるため、機密データの保護や本格的な認証には使えません。
- 学習履歴は Zustand persist によりブラウザの localStorage に保存されます。
