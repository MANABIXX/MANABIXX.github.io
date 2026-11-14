# Flutter Web migration inventory

Last inspected: 2026-11-14 (JST)  
Repository: `MANABIXX/MANABIXX.github.io`  
Production branch: `main`  
Production URL: https://manabixx.github.io/\nFlutter beta preview (after merge and Pages deployment): https://manabixx.github.io/flutter/

## Safety boundary

Correction (2026-11-14): `main` の `.github/workflows/pages.yml` は `flutter/build/web` を Pages artifact として公開する構成に変更済み。直近の main push に対する `Build and deploy Study` は成功しているため、Flutter Web は現在の本番配信経路である。一方、以下の機能同等性一覧には未移植項目が残る。旧SvelteKit/静的実装は互換・復旧用の資産として保持し、全ルート・履歴・アクセス境界の確認なしに削除しない。

## Existing route and feature inventory

| Existing area | Current implementation | Flutter migration status |
| --- | --- | --- |
| Home / Study dashboard | SvelteKit `src/routes/+page.svelte`; legacy `index.html` | Flutter migration dashboard implemented; full dashboard parity pending |
| Question practice | `src/lib/QuestionPractice.svelte`; `static/data/questions.json` | Flutter `/foundation` implemented with 1,180 existing records; local session history and wrong-answer IDs now persist per practice dataset; complete history migration and full UI parity pending |
| Public high-school exam practice | `src/routes/exam/`; legacy `public-exam.html`; `static/data/public-exam.json` | Flutter `/exam` implemented with 323 existing records and source-status display; source verification and UI parity pending |
| Additional dedicated practice | Existing isolated practice route and `static/data/kosen-questions.json` | Flutter `/kosen` implemented; kept off the public dashboard |
| Library | `src/routes/library/`; `static/data/knowledge-base.json` | Flutter `/library` implemented with 262 existing records, search, subject/grade/field filters and expandable details; saved-item parity pending |
| Mock exam | `src/routes/mock-exam/`; `static/data/mock-exams.json` | Flutter `/mock-exam` implemented with 100 records and five-subject selection; full mock flow/parity pending |
| Motivation | `src/routes/motivation/`; legacy `motivation.html` | Not started |
| Release notes | `src/routes/releases/`; legacy `release-notes.html` | Not started |
| Summary / notes | `src/routes/summary/`; legacy `summary.html`; `static/data/summary-foundation.json` | Flutter `/summary` implemented with 450 records; visual note/library parity pending |
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
6. Pages切替は `main` のworkflowですでに実施済み。以後は本番Flutter配信を前提に、未移植機能・既存URL・履歴・アクセス境界を優先して検証し、重大な回帰が見つかった場合のみ直前の正常デプロイへ戻す。

## Current stage

- Stage 1: isolated Flutter app scaffold and CI validation workflow.
- Stage 2: Flutter question-practice foundation, public exam, summary/foundation confirmation, five-subject mock practice, knowledge library, and a separate unlinked additional-practice route. Existing JSON data is loaded directly; practice selection, four-choice answering, explanations, results, library search and filters are implemented.
- Four public datasets audited: 1,180 foundation questions, 323 public-exam questions, 450 summary questions, and 100 mock questions. No duplicate IDs or malformed four-choice records were found in the inspected datasets.
- Still not migrated: motivation, release-note UI, workspace, private-content access boundary, Shitadumi app, full home/dashboard, full learning-history migration, PWA/offline behavior, and full browser/mobile/accessibility parity.
- Production deployment: Flutter Web root deployment is active on `main`; latest observed Pages workflow succeeded. Full feature parity is not yet established.
