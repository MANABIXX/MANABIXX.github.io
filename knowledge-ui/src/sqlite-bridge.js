import sqlite3InitModule from "@sqlite.org/sqlite-wasm";

let databasePromise;

async function getDatabase() {
  if (!databasePromise) {
    databasePromise = (async () => {
      const sqlite3 = await sqlite3InitModule({
        locateFile: (file) => new URL(file, import.meta.url).href,
      });
      const db = new sqlite3.oo1.DB();
      const response = await fetch(new URL("./knowledge-base.json", import.meta.url));
      if (!response.ok) throw new Error("Knowledge source could not be loaded");
      const source = await response.json();
      const entries = [
        ...(source.topicRecords ?? []),
        ...(source.authoredModules ?? []),
      ];
      db.exec({ sql: `
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
      ` });
      const insert = db.prepare(
        "INSERT OR REPLACE INTO knowledge (id, subject, field, grade, title, status, explanation) VALUES (?, ?, ?, ?, ?, ?, ?)"
      );
      try {
        for (const item of entries) {
          insert.bind([
            item.id ?? "",
            item.subject ?? "",
            item.field ?? "",
            item.grade ?? null,
            item.title ?? item.id ?? "",
            item.status ?? "outline",
            item.explanation ?? "",
          ]);
          insert.step();
          insert.reset();
        }
      } finally {
        insert.finalize();
      }
      return db;
    })();
  }
  return databasePromise;
}

window.searchKnowledge = async (query, subject) => {
  const db = await getDatabase();
  const rows = [];
  const pattern = query ? `%${query}%` : "%";
  db.exec({
    sql: `SELECT id, subject, field, grade, title, status, explanation
          FROM knowledge
          WHERE (? = 'all' OR subject = ?)
            AND (? = '' OR title LIKE ? OR field LIKE ? OR COALESCE(explanation, '') LIKE ? OR id LIKE ?)
          ORDER BY subject, field, title
          LIMIT 500`,
    bind: [subject, subject, query, pattern, pattern, pattern, pattern],
    rowMode: "object",
    resultRows: rows,
  });
  return rows;
};
