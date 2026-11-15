# MANABIXX Flutter Web migration workspace

This directory contains the Flutter Web application currently published at the GitHub Pages root by `.github/workflows/pages.yml`. The root deployment is active, but full parity with every legacy route, stored progress item, private-content boundary, and PWA behavior has not yet been established.

## Implemented migration slices

- `/`: Flutter migration dashboard with links to the implemented practice modules.
- Unsupported URLs: a dedicated not-found screen explains that the route is unavailable and provides a working return-to-home action.
- `/library`: existing `static/data/knowledge-base.json` (262 indexed/authored records); search by title, terms and explanation, filter by subject/grade/field, and expand learning details.
- Practice progress: local browser persistence for completed sessions, answer totals, and wrong-question IDs, separated by dataset/mode.
- `/foundation`: existing `static/data/questions.json` (1,180 records); 1,171 science/social questions selected from the 1,180-record source file, topic filters, 10/20/30/50/all question sessions, four-choice answers, explanations, and results.
- `/exam`: existing `static/data/public-exam.json` (323 records); science/social practice with source-status notes.
- `/summary`: existing `static/data/summary-foundation.json` (450 records); summary/foundation question sessions.
- `/mock-exam`: existing `static/data/mock-exams.json` (100 records); five-subject practice. The five-subject selector is limited to this mode.
- `/kosen`: separate additional practice route. It is intentionally not linked from the public migration dashboard.

The four public datasets above were audited on 2026-11-14: 2,053 questions total, no duplicate IDs, and no missing required fields / invalid four-choice answer indexes in the inspected records.

## Local checks

```sh
cd flutter
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /
```

## Migration rules

- Keep legacy source and recovery assets until route, data, progress, access-boundary, and PWA parity is verified; do not describe the Flutter root deployment as a beta preview.
- Port every existing public route and preserve deep links, question IDs, progress storage, settings, and PWA behavior.
- Do not replace real data with fixtures or present placeholder actions as working features.
- Do not introduce programming-language lessons into Study; Dart is implementation technology only.
- Use `docs/flutter-migration-inventory.md` as the complete parity checklist.


## 公開データの範囲

GitHub PagesへコピーするJSONは、Flutterの各ルートが実際に利用する次の9ファイルに限定しています。

- `foundation-training.json`
- `knowledge-base.json`
- `kosen-math-section-1.json`
- `kosen-questions.json`
- `mock-exams.json`
- `public-exam.json`
- `questions.json`
- `summary-foundation.json`
- `to-you.json`

`private-*`、`s-exclusive*`、その他の未使用JSONは公開成果物へコピーしません。これはPages成果物の境界であり、GitHub上の公開元リポジトリに残るファイルを非公開化するものではありません。
