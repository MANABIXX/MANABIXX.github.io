# Daily question batches

This folder is the reviewed content inbox for the daily question importer.

Add one UTF-8 JSON file per category, named `YYYY-MM-DD-foundation.json`, `YYYY-MM-DD-publicExam.json`, or `YYYY-MM-DD-kosen.json`. The top-level shape is:

```json
{
  "date": "2026-11-15",
  "category": "foundation",
  "questions": []
}
```

Allowed categories:
- `foundation` → `static/data/questions.json`
- `publicExam` → `static/data/public-exam.json`
- `kosen` → `static/data/kosen-questions.json`

Every batch must contain at least 10 original questions for each of the five subjects
(`japanese`, `math`, `english`, `science`, `social`). Each item must have a unique
ID beginning with `daily-YYYY-MM-DD-`, a prompt, exactly four options, a correct index
from 0 to 3, and a meaningful explanation.

The scheduled GitHub Action validates and imports reviewed batches idempotently. It does
not invent questions or scrape copyrighted exam papers: a human/editor must author and
review the batch before it enters this folder. Existing IDs cannot silently overwrite
different content.
