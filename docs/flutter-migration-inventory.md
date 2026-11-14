# Flutter Web migration inventory

Last inspected: 2026-11-14 (JST)  
Repository: `MANABIXX/MANABIXX.github.io`  
Production branch: `main`  
Production URL: https://manabixx.github.io/

## Safety boundary

The production Pages workflow currently builds the SvelteKit application from the repository root. The legacy static site and a separate Next.js prototype also exist in this repository. This Flutter workspace is isolated and must not be deployed to production until parity checks pass. Do not delete or overwrite any of those implementations during the foundation stage.

## Existing route and feature inventory

| Existing area | Current implementation | Flutter migration status |
| --- | --- | --- |
| Home / Study dashboard | SvelteKit `src/routes/+page.svelte`; legacy `index.html` | Not started |
| Question practice | `src/lib/QuestionPractice.svelte`; `static/data/questions.json` | Not started |
| Public high-school exam practice | `src/routes/exam/`; legacy `public-exam.html`; `static/data/public-exam.json` | Not started |
| Kosen-specific mode | `src/routes/kosen/`; `static/data/kosen-questions.json` | Not started |
| Library | `src/routes/library/` | Not started |
| Mock exam | `src/routes/mock-exam/`; `static/data/mock-exams.json` | Not started |
| Motivation | `src/routes/motivation/`; legacy `motivation.html` | Not started |
| Release notes | `src/routes/releases/`; legacy `release-notes.html` | Not started |
| Summary / notes | `src/routes/summary/`; legacy `summary.html`; summary JSON data | Not started |
| Workspace | `src/routes/workspace/` | Not started |
| Private content | legacy `private.html`, `n-exclusive.html`, `s-exclusive.html`; matching JSON | Not started; audit access boundary first |
| Shitadumi mode | `shitadumi/` static app, articles, mock exams, opinion, PWA and release notes | Not started |
| PWA / offline | `src/service-worker.js`, manifests, legacy service workers | Not started |
| Next.js prototype | `next-app/` | Inventory only; not assumed to be production |
| Code lab | `src/routes/code-lab/`, `src/lib/code-lab.ts` | Audit purpose and origin before deciding whether to retain |

## Data and state compatibility requirements

- Preserve question IDs and the existing JSON schemas; do not regenerate or renumber content.
- Preserve local learning history, bookmarks, wrong-answer records, settings, and theme preferences. Determine the exact storage keys and versioning before implementing migration.
- Keep private datasets out of public routes and static downloads unless their current exposure has been explicitly assessed.
- Keep the existing public URLs and verify direct navigation, reload, browser back/forward, and trailing-slash behavior.
- Preserve the independent PWA identity, icon, manifest, offline cache scope, and update behavior.

## Deployment and cutover gates

1. Complete a source-level route, data, persistence, and access-control audit.
2. Port one self-contained screen and its real data path at a time.
3. Add parity tests for each migrated route and user action.
4. Verify Flutter analyze, widget tests, release web build, deep links, mobile layout, accessibility, and offline behavior.
5. Compare all public routes and stored data against the current production implementation.
6. Only after every gate passes, prepare a separately reviewed Pages cutover. Until then, keep the existing production Pages workflow unchanged.

## Current stage

- Stage 1: isolated Flutter app scaffold and CI validation workflow.
- Not yet migrated: all existing production routes and features.
- Production deployment: unchanged.
