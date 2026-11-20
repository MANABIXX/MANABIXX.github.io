//! Lossless, idempotent import planning for legacy Flutter preferences.
//! This module parses a backup bundle but never deletes or mutates source keys.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct LegacyEntry {
    pub key: String,
    pub value: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct LegacyBackup {
    pub format_version: u32,
    pub exported_at: String,
    pub entries: Vec<LegacyEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ImportReport {
    pub recognized_entries: usize,
    pub ignored_entries: usize,
    pub malformed_json_entries: Vec<String>,
    pub duplicate_keys: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ImportPlan {
    pub report: ImportReport,
    /// Exact source values, retained for a later transactional SQLite adapter.
    pub source_values: BTreeMap<String, serde_json::Value>,
}

#[derive(Debug, thiserror::Error, PartialEq, Eq)]
pub enum BackupError {
    #[error("unsupported backup format version {0}")]
    UnsupportedVersion(u32),
    #[error("duplicate source key: {0}")]
    DuplicateKey(String),
}

fn is_manabixx_key(key: &str) -> bool {
    key.starts_with("manabixx.learning.")
        || key.starts_with("manabixx.mode.kosen.")
        || key == "manabixx-planner-tasks-v1"
        || key.starts_with("manabixx-planner-note-")
        || key.starts_with("manabixx-focus-count-")
}

pub fn plan_import(backup: &LegacyBackup) -> Result<ImportPlan, BackupError> {
    if backup.format_version != 1 {
        return Err(BackupError::UnsupportedVersion(backup.format_version));
    }
    let mut source_values = BTreeMap::new();
    let mut ignored_entries = 0;
    let mut recognized_entries = 0;
    let mut duplicate_keys = Vec::new();

    for entry in &backup.entries {
        if !is_manabixx_key(&entry.key) {
            ignored_entries += 1;
            continue;
        }
        if source_values.contains_key(&entry.key) {
            duplicate_keys.push(entry.key.clone());
            return Err(BackupError::DuplicateKey(entry.key.clone()));
        }
        recognized_entries += 1;
        source_values.insert(entry.key.clone(), entry.value.clone());
    }

    Ok(ImportPlan {
        report: ImportReport {
            recognized_entries,
            ignored_entries,
            malformed_json_entries: Vec::new(),
            duplicate_keys,
        },
        source_values,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn recognizes_learning_and_workspace_keys_without_rewriting_values() {
        let backup = LegacyBackup {
            format_version: 1,
            exported_at: "2026-11-16T00:00:00+09:00".into(),
            entries: vec![
                LegacyEntry {
                    key: "manabixx.learning._data_science_json.history".into(),
                    value: serde_json::json!([{"total": 10, "score": 8}]),
                },
                LegacyEntry {
                    key: "manabixx-planner-note-2026-11-16".into(),
                    value: serde_json::json!("復習する"),
                },
                LegacyEntry {
                    key: "unrelated.preference".into(),
                    value: serde_json::json!(true),
                },
            ],
        };
        let plan = plan_import(&backup).unwrap();
        assert_eq!(plan.report.recognized_entries, 2);
        assert_eq!(plan.report.ignored_entries, 1);
        assert_eq!(
            plan.source_values["manabixx-planner-note-2026-11-16"],
            serde_json::json!("復習する")
        );
    }

    #[test]
    fn rejects_duplicate_keys_to_prevent_ambiguous_imports() {
        let backup = LegacyBackup {
            format_version: 1,
            exported_at: String::new(),
            entries: vec![
                LegacyEntry { key: "manabixx-planner-tasks-v1".into(), value: serde_json::json!([]) },
                LegacyEntry { key: "manabixx-planner-tasks-v1".into(), value: serde_json::json!([1]) },
            ],
        };
        assert_eq!(
            plan_import(&backup),
            Err(BackupError::DuplicateKey("manabixx-planner-tasks-v1".into()))
        );
    }

    #[test]
    fn rejects_unknown_backup_versions() {
        let backup = LegacyBackup { format_version: 99, exported_at: String::new(), entries: vec![] };
        assert_eq!(plan_import(&backup), Err(BackupError::UnsupportedVersion(99)));
    }
}
