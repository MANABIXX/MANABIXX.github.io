# MANABIXX 2.0 — Rebuild architecture

Status: foundation branch; not production cutover.

## Product boundaries

- Main learning app: Flutter / Dart remains the cross-platform shell during migration.
- Shared learning domain: Rust crate at `rust-core/`; single source of truth for question validation, answer records and review scheduling.
- Knowledge library: Rust + Leptos WebAssembly, using SQLite-Wasm for browser-side query and persistence.
- Independent blog: separate `MANABIXX/blog` repository, rebuilt independently with Hexo + hexo-admin and a dedicated theme. The editor runs locally; GitHub Pages receives generated static files. Blog dependencies, posts and admin functions do not belong in the app repository.
- Delivery: GitHub Pages remains static hosting. No server-only feature may be represented as private merely because it is noindex or hidden in client UI.

## Migration rules

1. Preserve every existing question ID and the current JSON fields. The Rust model accepts the existing field/question/choices/answerIndex aliases as well as Flutter data field names.
2. Keep current Flutter routes and data files working until parity tests prove the replacement.
3. Move domain rules before moving screens: validation, answer scoring, attempt records, mastery and review scheduling belong in Rust.
4. Use SQLite as the durable local store for question metadata, attempts, mastery, bookmarks and notes. Version every schema migration; never silently discard old SharedPreferences/localStorage records.
5. Flutter remains app navigation and mobile shell. Leptos is used for web-first knowledge/search surfaces, not as a reason to duplicate the whole app UI.
6. Keep the blog independent. Blog article source remains Markdown; its publishing toolchain and design are maintained in its own repository.
7. Every feature migration includes data migration, unit tests, direct URL checks, accessibility/mobile checks, offline checks and release-note updates.

## Work stages

- A. Rust domain foundation: implemented in this branch (`rust-core/`), with four-choice validation, answer attempts and deterministic mastery scheduling tests.
- B. SQLite schema and migration adapter: next; inspect actual SharedPreferences keys and all existing question JSON schemas first.
- C. Flutter-to-Rust boundary: expose the stable Rust domain through FFI/WASM without changing current production behavior.
- D. Leptos knowledge/search UI: consolidate query logic and persist bookmarks/notes through SQLite-Wasm.
- E. Migrate learning flows one by one: foundation practice, public exam, Kosen practice, mock exam, weak-question review, workspace and progress.
- F. Verify feature parity, then switch production routes. Keep rollback path until live checks pass.

## Non-goals

- No deletion of legacy screens/data during migration.
- No false claim that client-side passwords protect private content.
- No production deployment from this foundation branch.
- No mixing MANABIXX blog content into the app repository.
