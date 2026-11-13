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
