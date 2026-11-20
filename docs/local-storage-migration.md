# Existing local data migration inventory

Do not clear SharedPreferences or localStorage during the MANABIXX 2.0 migration. This file records observed legacy keys before writing an importer.

## Observed Flutter SharedPreferences keys

| Feature | Key | Payload |
|---|---|---|
| Foundation practice history | `manabixx.learning.${dataPath.replaceAll('/', '_')}.history` | JSON array; each row includes completedAt, total, score and subject totals |
| Foundation wrong-answer queue | `manabixx.learning.${dataPath.replaceAll('/', '_')}.wrong` | string list of question IDs |
| Kosen practice history | `manabixx.mode.kosen.history` or `manabixx.mode.kosen.history.${dataPath.replaceAll('/', '_')}` | JSON array |
| Kosen wrong-answer queue | history key + `.wrong` | string list of question IDs |
| Kosen custom questions | history key + `.custom` | JSON array of custom questions |
| Workspace tasks | `manabixx-planner-tasks-v1` | JSON task list |
| Workspace daily note | `manabixx-planner-note-YYYY-MM-DD` | plain text |
| Workspace focus count | `manabixx-focus-count-YYYY-MM-DD` | string-encoded count |

## SQLite v1 target

`rust-core/migrations/0001_learning_store.sql` creates versioned tables for questions, answer attempts, mastery, bookmarks, wrong-answer queues, tasks, notes and focus sessions.

## Import requirements

1. Read legacy values without deleting or rewriting them.
2. Parse each value independently; malformed values are reported and retained for recovery.
3. Use stable question IDs and dataset identifiers; do not infer a dataset from display names.
4. Import idempotently using primary keys and a migration ledger.
5. Compare imported row counts and sample values against the original keys.
6. Only offer legacy-key cleanup after a successful backup, full parity check and explicit release approval.
7. Current code inspection did not yet identify a durable bookmark key in the Flutter question screens; do not invent one.

## Important

These keys are not yet migrated. The SQL schema is a target contract only; production continues using the current storage until the importer is implemented and tested.
