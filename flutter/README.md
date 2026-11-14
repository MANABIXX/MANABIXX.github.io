# MANABIXX Flutter Web migration foundation

This directory is an isolated migration workspace. It is not the production Pages entry point.

## Local checks

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /
```

## Migration rules

- Keep the existing production site and GitHub Pages workflow unchanged until route and feature parity is verified.
- Port every existing public route and preserve deep links, question IDs, progress storage, settings, and PWA behavior.
- Do not replace real data with fixtures or present placeholder actions as working features.
- Do not introduce programming-language lessons into Study; Dart is implementation technology only.
- Use the route inventory in `docs/flutter-migration-inventory.md` as the parity checklist.
