# Flutter Web migration inventory

Last inspected: 2026-11-19 (JST)  
Repository: `MANABIXX/MANABIXX.github.io`  
Production branch: `main`  
Production URL: https://manabixx.github.io/ (Flutter Web at Pages root)

## Safety boundary

Correction (2026-11-14): `main` の `.github/workflows/pages.yml` は `flutter/build/web` を Pages artifact として公開する構成に変更済み。直近の main push に対する `Build and deploy Study` は成功しているため、Flutter Web は現在の本番配信経路である。一方、以下の機能同等性一覧には未移植項目が残る。旧SvelteKit/静的実装は互換・復旧用の資産として保持し、全ルート・履歴・アクセス境界の確認なしに削除しない。

## Existing route and feature inventory

| Existing area | Current implementation | Flutter migration status |
| --- | --- | --- |
| Home / Study dashboard | SvelteKit `src/routes/+page.svelte`; legacy `index.html` | Flutter migration dashboard implemented; full dashboard parity pending |
| Unsupported route handling | SvelteKit/legacy routing and static 404 fallback | Flutter now shows a dedicated not-found screen and a working return-to-home action instead of silently displaying the dashboard; full legacy URL mapping remains pending |
| Question practice | `src/lib/QuestionPractice.svelte`; `static/data/questions.json` | Flutter `/foundation` implemented with 1,260 existing records; local session history and wrong-answer IDs now persist per practice dataset; complete history migration and full UI parity pending |
| Public high-school exam practice | `src/routes/exam/`; legacy `public-exam.html`; `static/data/public-exam.json` | Flutter `/exam` implemented with 343 records (science 189, social 154) and source-status display; the current public-exam dataset covers only these two subjects, so five-subject expansion, source verification and UI parity remain pending |
| Additional dedicated practice | Existing isolated practice route and `static/data/kosen-questions.json` | Flutter `/kosen` implemented; kept off the public dashboard |
| Foundation training / 下積み問題 | `static/data/foundation-training.json` | Flutter `/practice/foundation-training/study` uses the five-subject practice screen and selects exactly 10 random questions per subject (50 total) from its dedicated 75-record bank plus the approved question datasets. The mode shows separate date countdowns for 県立高校入試 and 私立高校入試. The labels are school-neutral; existing local date-storage keys are retained for compatibility. The password gate is client-side only, not server-side access control. |
| Library | `src/routes/library/`; `static/data/knowledge-base.json` | Flutter `/library` implemented with 262 existing records, search, subject/grade/field filters and expandable details; saved-item parity pending |
| Mock exam | `src/routes/mock-exam/`; `static/data/mock-exams.json` | Flutter `/mock-exam` implemented with 100 records and five-subject selection; full mock flow/parity pending |
| Motivation | legacy `src/routes/motivation/` and `motivation.html`; Flutter `/to-you` message screen; separate `MANABIXX/blog` site | Flutter keeps the short daily-message experience and links to the independent Zola blog at `https://manabixx.github.io/blog/` and a separate Quartz v4 knowledge summary at `https://manabixx.github.io/blog/summary/`. Long-form motivation/study-habit articles are managed in that repository, not duplicated into the Flutter app. The blog repository remains read-only during morning runs |
| Release notes | `src/routes/releases/`; legacy `release-notes.html`; Flutter `/releases` and `/release-notes` | Flutter release-note screen is implemented; full historical entry parity and archive migration remain pending |
| Summary / notes | `src/routes/summary/`; legacy `summary.html`; `static/data/summary-foundation.json` | Flutter `/summary` implemented with 450 records; visual note/library parity pending |
| Workspace | `src/routes/workspace/` | Flutter `/workspace` implemented: daily task list, 15/25/45/60-minute focus timer, question-backed flashcards, and daily notes. Uses the legacy local persistence keys; cross-device sync is not provided. Widget tests added; browser/mobile parity still needs production verification |
| Private content | legacy `private.html`, `n-exclusive.html`, `s-exclusive.html`; matching JSON | Not started; audit access boundary first |
| Shitadumi mode | `shitadumi/` static app, articles, mock exams, opinion, PWA and release notes | Flutter now preserves `/shitadumi/opinion/` and `/practice/foundation-training/opinion` as a read-only paused-feedback notice; no form, submission, or draft storage is exposed. Home/practice, mock exams, articles, PWA/install guide, and full release-history parity remain pending |
| PWA / offline | Flutter service worker, root resource manifest, mode-specific manifests | Flutter runtime and nine explicitly approved route datasets are precached; weekly Periodic Background Sync is browser-dependent |
| Next.js prototype | `next-app/` | Inventory only; not assumed to be production |
| Code lab | Former `src/routes/code-lab/`, `src/lib/code-lab.ts` | Removed 2026-11-15: route, legacy menu entry and sample module removed; no Flutter route or sitemap entry exists |

## Data and state compatibility requirements

- Preserve question IDs and the existing JSON schemas; do not regenerate or renumber content.
- Preserve local learning history, bookmarks, wrong-answer records, settings, and theme preferences. Determine the exact storage keys and versioning before implementing migration.
- The Pages artifact copies only the nine-file Flutter route allowlist; `private-*` / `s-exclusive*` legacy JSON is excluded from the deployed `data/` directory. The source files in the public `MANABIXX/content-registry` repository remain publicly downloadable from GitHub and are not protected by filename or registry metadata. The client-side mode password is not server authentication.
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
- Four public datasets audited: 1,260 foundation questions, 343 public-exam questions, 450 summary questions, and 100 mock questions. No duplicate IDs or malformed four-choice records were found in the inspected datasets.
- Still not migrated or not yet parity-verified: full motivation archive, release-note history parity, private-content access boundary, Shitadumi app, full home/dashboard, full learning-history migration, and full browser/mobile/accessibility parity.
- 2026-11-16: `/workspace` was migrated with task, timer, flashcard and note functions. It reuses the previous local persistence keys; cross-device sync remains unsupported.
- 2026-11-18: `static/data/questions.json` contains 1,260 validated records; `static/data/public-exam.json` contains 343 records; `static/data/foundation-training.json` contains 75 records (15 per subject), including 50 newly added questions. The 50 regular questions are split across 30 five-subject practice questions in `questions.json` and 20 new science/social questions in `public-exam.json` (10 each). The daily importer now validates subject coverage by destination and recalculates public-exam counts.
- 2026-11-15: unsupported Flutter routes now render an explicit not-found screen with a return-to-home action; the route fallback is covered by a widget test.
- Production deployment: Flutter Web root deployment is active on `main`; the latest observed Pages workflow for the migration branch succeeded, but the open PR #19 is not mergeable and its result is not evidence of full feature parity.


## Privacy boundary follow-up (2026-11-15)

- Current public UI, README, changelog, generated foundation-training metadata, and exam display titles no longer show individual school names. The old school-specific article paths were removed from the current tree and from the legacy service-worker shell.
- Historical Git commits still contain earlier versions of those files. No history rewrite was performed; old commit objects may remain publicly reachable. A complete historical purge would require a separately approved history rewrite and cache review.
- The legacy mode's password check is client-side only and is not server-side access control. Do not treat the mode or noindex as private storage.

## 2026-11-19 execution update

- Current inspected main HEAD: `35e3502c0798209b2690ab346545822f76435a97`.
- Fixed two Rust + Leptos build errors in `knowledge-ui/src/main.rs`: an unquoted middle dot in the view macro and incompatible opaque component return types in the blog/library switch. The switch now uses Leptos `Show`; the heading separator uses ASCII.
- The current `Build and deploy Study` run (44410945932) has already passed registry synchronization, question-data validation, TypeScript/Svelte checks, PWA checks, Flutter analyze, Flutter tests, and Flutter Web release build. At the last check it was still installing Trunk; Leptos/WASM compilation, artifact upload, and Pages deployment had not yet completed.
- The previous Android release run built and tested the APK successfully and uploaded a workflow artifact, but the final Release asset check failed because the uploaded asset was named `app-release.apk` while the workflow expected `MANABIXX-Android.apk`. The workflow now copies the verified APK to the expected filename before Release upload. The new Android run (44410927897) was still building at the last check; release verification remains pending.
- No question datasets, IDs, saved-progress formats, routes, or access boundaries were changed in this run. The public content-registry still contains legacy `private-*` files; the main Pages workflow's nine-file allowlist excludes them from the deployed Flutter data bundle, but the registry repository itself is public and those files remain directly downloadable there.


## 2026-11-21 execution update

- Ported the legacy paused-feedback page to Flutter at `/shitadumi/opinion/` and added the equivalent `/practice/foundation-training/opinion` route. The page is informational only: it does not accept input, save drafts, or submit feedback.
- Added a widget test for the legacy route and a root-build route-presence check so the route cannot silently disappear from the Pages artifact.
- Remaining Shitadumi migration work is unchanged: the full workspace/practice flow, mock exams, advice articles, install guide/PWA behavior, and complete release-history parity still require separate migration and parity checks.
