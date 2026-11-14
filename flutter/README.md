# MANABIXX Flutter Web migration workspace

Flutter Web is the production GitHub Pages app and is deployed at https://manabixx.github.io/. The former SvelteKit source remains in the repository for reference and CI checks, but the Pages artifact is now the Flutter build.

## Implemented migration slices

- `/`: Flutter migration dashboard with links to the implemented practice modules.
- `/library`: existing `static/data/knowledge-base.json` (262 indexed/authored records); search by title, terms and explanation, filter by subject/grade/field, and expand learning details.
- Practice progress: local browser persistence for completed sessions, answer totals, and wrong-question IDs, separated by dataset/mode.
- `/foundation`: existing `static/data/questions.json` (1,180 records); 1,171 science/social questions selected from the 1,180-record source file, topic filters, 10/20/30/50/all question sessions, four-choice answers, explanations, and results.
- `/exam`: existing `static/data/public-exam.json` (323 records); science/social practice with source-status notes.
- `/summary`: existing `static/data/summary-foundation.json` (450 records); summary/foundation question sessions.
- `/mock-exam`: existing `static/data/mock-exams.json` (100 records); five-subject practice. The five-subject selector is limited to this mode.
- `/kosen`: separate additional practice route. It is intentionally not linked from the public migration dashboard.

The four public datasets above were audited on 2026-11-14: 2,053 questions total, no duplicate IDs, and no missing required fields / invalid four-choice answer indexes in the inspected records.

## Offline behavior\n\n- `npm run prepare:flutter-offline` hashes the seven JSON datasets referenced by Flutter routes and generates a versioned dataset manifest and service worker. Unrelated/private/supplementary JSON files are deliberately excluded.\n- `npm run assemble:flutter-root` copies those datasets and the app icon into the Flutter output, creates a root `404.html` fallback, and generates a manifest for every built app resource.\n- During service-worker installation, the full Flutter runtime, app resources, and approved question datasets are cached before the new worker activates. Once installation completes, practice screens can continue offline.\n- Every app launch checks for service-worker updates. Browsers supporting Periodic Background Sync can also refresh the dataset cache weekly; other browsers refresh on the next launch. Background execution remains subject to browser and OS support.\n\n## Production build\n\nRun from the repository root after generating learning data:\n\n```sh\nnpm install\nnpm run sync:registry\nnpm run generate:kosen\nnpm run validate:kosen\nnpm run generate:foundation-training\nnpm run prepare:flutter-offline\nnpm run fetch:flutter-fonts\n\ncd flutter\nflutter pub get\nflutter analyze\nflutter test\nflutter build web --release --wasm --base-href /\ncd ..\nnpm run assemble:flutter-root\nnpm run validate:flutter-root\n```\n\nThe Pages workflow performs the same checks and deploys `flutter/build/web` at `/`.\n\n## Routing\n\nFlutter uses path URL strategy. `404.html` is an exact copy of the Flutter entry point, so GitHub Pages deep links such as `/practice/kosen` and `/summary/science` boot Flutter while preserving the requested path. Mode-specific PWA manifests now use root-scoped URLs and distinct start URLs.\n\n## Local checks

```sh
cd flutter
flutter pub get
flutter analyze
flutter test
flutter build web --release --wasm --base-href /
```

## Migration rules

- The Flutter root cutover is intentional; the SvelteKit source remains in-repository but is no longer deployed by Pages. This does not imply complete feature parity.
- Port every existing public route and preserve deep links, question IDs, progress storage, settings, and PWA behavior.
- Do not replace real data with fixtures or present placeholder actions as working features.
- Do not introduce programming-language lessons into Study; Dart is implementation technology only.
- Use `docs/flutter-migration-inventory.md` as the complete parity checklist.
