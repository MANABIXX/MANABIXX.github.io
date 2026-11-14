# Flutter Web migration inventory

Last inspected: 2026-11-14 (JST)  
Repository: `MANABIXX/MANABIXX.github.io`  
Production branch: `main`  
Production URL: https://manabixx.github.io/ (Flutter Web root deployment)

## Deployment decision and known limitations

The Pages workflow is being switched to the Flutter Web build at `/` by explicit product direction. The SvelteKit and legacy sources remain in the repository, but they are no longer the Pages deployment artifact after this cutover. This is a root-app deployment, not a claim that every former route has been ported.

Motivation, release notes, workspace, private-content boundaries, the separate Shitadumi app, and full learning-history migration remain incomplete in Flutter. Users who relied on those former routes will not find them in the root app until they are migrated. Do not describe this cutover as full feature parity.

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

## Deployment and cutover verification

- The Pages workflow builds Flutter with `--base-href /`, copies the Flutter route datasets into the root output, and publishes a matching `404.html` for direct navigation and reload on clean URLs.
- `prepare:flutter-offline` hashes the seven JSON datasets used by Flutter routes and generates a versioned data manifest and worker. Supplementary/private JSON files not referenced by Flutter are excluded.
- `assemble:flutter-root` copies the approved datasets and icon, generates an app-resource manifest, and injects a build version into the worker.
- The service worker pre-caches Flutter runtime resources and approved problem datasets before activation; it keeps the previous cache until the new cache is ready. The app checks for worker updates on launch. Browsers supporting Periodic Background Sync can refresh datasets weekly.
- Background sync while the app is closed depends on browser and OS support; the guaranteed fallback is an update check on the next launch.
- This root deployment does not complete the remaining route, private-content, accessibility, or stored-progress parity items listed above.

## Current stage

- Stage 1: isolated Flutter app scaffold and CI validation workflow.
- Stage 2: Flutter question-practice foundation, public exam, summary/foundation confirmation, five-subject mock practice, knowledge library, and a separate unlinked additional-practice route. Existing JSON data is loaded directly; practice selection, four-choice answering, explanations, results, library search and filters are implemented.
- Four public datasets audited: 1,180 foundation questions, 323 public-exam questions, 450 summary questions, and 100 mock questions. No duplicate IDs or malformed four-choice records were found in the inspected datasets.
- Still not migrated: motivation, release-note UI, workspace, private-content access boundary, Shitadumi app, full learning-history migration, and full browser/mobile/accessibility parity. Offline caching is now implemented for the Flutter app and its seven route datasets only.
- Production deployment: Flutter Web at the Pages root after this cutover; SvelteKit and legacy sources remain in the repository but are not the deployed app.
