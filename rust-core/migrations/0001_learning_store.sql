PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  applied_at_ms INTEGER NOT NULL,
  checksum TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS questions (
  id TEXT PRIMARY KEY,
  dataset TEXT NOT NULL,
  subject TEXT NOT NULL,
  topic TEXT NOT NULL,
  level TEXT NOT NULL,
  prompt TEXT NOT NULL,
  options_json TEXT NOT NULL CHECK (json_valid(options_json)),
  correct_index INTEGER NOT NULL CHECK (correct_index BETWEEN 0 AND 3),
  explanation TEXT NOT NULL,
  source_note TEXT,
  source_ref TEXT,
  updated_at_ms INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_questions_dataset_subject
  ON questions(dataset, subject);
CREATE INDEX IF NOT EXISTS idx_questions_topic
  ON questions(dataset, topic);

CREATE TABLE IF NOT EXISTS answer_attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_id TEXT NOT NULL,
  dataset TEXT NOT NULL,
  selected_index INTEGER NOT NULL CHECK (selected_index BETWEEN 0 AND 3),
  is_correct INTEGER NOT NULL CHECK (is_correct IN (0, 1)),
  elapsed_ms INTEGER NOT NULL DEFAULT 0 CHECK (elapsed_ms >= 0),
  answered_at_ms INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_attempts_dataset_time
  ON answer_attempts(dataset, answered_at_ms DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_question
  ON answer_attempts(question_id, answered_at_ms DESC);

CREATE TABLE IF NOT EXISTS mastery (
  question_id TEXT NOT NULL,
  dataset TEXT NOT NULL,
  repetitions INTEGER NOT NULL DEFAULT 0,
  interval_days INTEGER NOT NULL DEFAULT 0,
  ease_factor REAL NOT NULL DEFAULT 2.5,
  due_at_ms INTEGER NOT NULL DEFAULT 0,
  correct_count INTEGER NOT NULL DEFAULT 0,
  incorrect_count INTEGER NOT NULL DEFAULT 0,
  updated_at_ms INTEGER NOT NULL,
  PRIMARY KEY(dataset, question_id)
);
CREATE INDEX IF NOT EXISTS idx_mastery_due
  ON mastery(dataset, due_at_ms);

CREATE TABLE IF NOT EXISTS bookmarks (
  dataset TEXT NOT NULL,
  question_id TEXT NOT NULL,
  created_at_ms INTEGER NOT NULL,
  PRIMARY KEY(dataset, question_id)
);

CREATE TABLE IF NOT EXISTS wrong_queue (
  dataset TEXT NOT NULL,
  question_id TEXT NOT NULL,
  first_wrong_at_ms INTEGER NOT NULL,
  last_wrong_at_ms INTEGER NOT NULL,
  PRIMARY KEY(dataset, question_id)
);

CREATE TABLE IF NOT EXISTS workspace_tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  is_done INTEGER NOT NULL DEFAULT 0 CHECK (is_done IN (0, 1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  updated_at_ms INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS workspace_notes (
  note_date TEXT PRIMARY KEY,
  body TEXT NOT NULL,
  updated_at_ms INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS workspace_focus_sessions (
  id TEXT PRIMARY KEY,
  note_date TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
  completed_at_ms INTEGER NOT NULL
);
