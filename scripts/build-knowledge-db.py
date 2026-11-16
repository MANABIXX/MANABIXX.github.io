import json
import sqlite3
from pathlib import Path

root = Path(__file__).resolve().parents[1]
source = json.loads((root / "data/knowledge-base.json").read_text(encoding="utf-8"))
out = root / "data/knowledge.sqlite"
if out.exists():
    out.unlink()
db = sqlite3.connect(out)
db.executescript("""
PRAGMA journal_mode=DELETE;
PRAGMA foreign_keys=ON;
CREATE TABLE knowledge (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL,
  field TEXT NOT NULL,
  grade INTEGER,
  title TEXT NOT NULL,
  status TEXT NOT NULL,
  explanation TEXT
);
CREATE INDEX idx_knowledge_subject_field ON knowledge(subject, field);
CREATE INDEX idx_knowledge_title ON knowledge(title);
""")
records = list(source.get("topicRecords", [])) + list(source.get("authoredModules", []))
for item in records:
    db.execute(
        "INSERT OR REPLACE INTO knowledge VALUES (?, ?, ?, ?, ?, ?, ?)",
        (
            item.get("id", ""), item.get("subject", ""), item.get("field", ""),
            item.get("grade"), item.get("title", item.get("id", "")),
            item.get("status", "outline"), item.get("explanation") or "",
        ),
    )
db.commit()
count = db.execute("SELECT COUNT(*) FROM knowledge").fetchone()[0]
assert count == len(records) and count > 0, f"SQLite row count mismatch: {count} / {len(records)}"
db.close()
print(f"Built SQLite knowledge database: {count} rows -> {out}")
