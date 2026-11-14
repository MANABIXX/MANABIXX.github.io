import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const inbox = path.join(root, 'content', 'daily-questions');
const destinations = {
  foundation: 'questions.json',
  publicExam: 'public-exam.json',
  kosen: 'kosen-questions.json',
};
const subjects = ['japanese', 'math', 'english', 'science', 'social'];
const valid = (q, file) => {
  if (!q || typeof q !== 'object' || typeof q.id !== 'string' ||
      !subjects.includes(q.subject) || typeof q.prompt !== 'string' ||
      !Array.isArray(q.options) || q.options.length !== 4 ||
      q.options.some((item) => typeof item !== 'string' || !item.trim()) ||
      !Number.isInteger(q.correct) || q.correct < 0 || q.correct > 3 ||
      typeof q.explanation !== 'string' || !q.explanation.trim()) {
    throw new Error('Invalid four-choice question in ' + file + ': ' + (q?.id ?? 'unknown'));
  }
};

let entries = [];
try {
  entries = (await fs.readdir(inbox)).filter((name) => /^\d{4}-\d{2}-\d{2}\.json$/.test(name)).sort();
} catch (error) {
  if (error.code !== 'ENOENT') throw error;
}
if (!entries.length) {
  console.log('No daily question batches queued; import skipped.');
  process.exit(0);
}

const dataRoot = path.join(root, 'static', 'data');
const changed = [];
for (const filename of entries) {
  const batch = JSON.parse(await fs.readFile(path.join(inbox, filename), 'utf8'));
  const filenameMatch = filename.match(/^(\\d{4}-\\d{2}-\\d{2})-(foundation|publicExam|kosen)\\.json$/);
  if (!filenameMatch || batch.date !== filenameMatch[1] || batch.category !== filenameMatch[2] || !Array.isArray(batch.questions)) {
    throw new Error('Daily batch filename/date/category mismatch: ' + filename);
  }
  const counts = Object.fromEntries(subjects.map((subject) => [subject, 0]));
  const batchIds = new Set();
  for (const question of batch.questions) {
    valid(question, filename);
    if (batchIds.has(question.id)) throw new Error('Duplicate question ID in ' + filename + ': ' + question.id);
    batchIds.add(question.id);
    counts[question.subject]++;
    if (!question.id.startsWith('daily-' + batch.date + '-')) {
      throw new Error('Question ID must begin with daily-' + batch.date + '-: ' + question.id);
    }
  }
  for (const subject of subjects) {
    if (counts[subject] < 10) {
      throw new Error(filename + ' needs at least 10 ' + subject + ' questions; found ' + counts[subject]);
    }
  }

  const target = path.join(dataRoot, destinations[batch.category]);
  const current = JSON.parse(await fs.readFile(target, 'utf8'));
  const existing = new Map((current.questions ?? []).map((question) => [question.id, question]));
  for (const question of batch.questions) {
    const previous = existing.get(question.id);
    if (previous && JSON.stringify(previous) !== JSON.stringify(question)) {
      throw new Error('Question ID collision with different content: ' + question.id);
    }
    existing.set(question.id, question);
  }
  current.questions = [...existing.values()];
  await fs.writeFile(target, JSON.stringify(current, null, 2) + '\n');
  if (batch.category === 'kosen') {
    const mathTarget = path.join(dataRoot, 'kosen-math-section-1.json');
    const mathData = JSON.parse(await fs.readFile(mathTarget, 'utf8'));
    const mathById = new Map((mathData.questions ?? []).map((question) => [question.id, question]));
    for (const question of batch.questions.filter((item) => item.subject === 'math')) {
      mathById.set(question.id, question);
    }
    mathData.questions = [...mathById.values()];
    await fs.writeFile(mathTarget, JSON.stringify(mathData, null, 2) + '\n');
  }
  changed.push(destinations[batch.category]);
  console.log('Imported ' + batch.questions.length + ' questions from ' + filename + ' into ' + destinations[batch.category]);
}
console.log('Daily import complete: ' + [...new Set(changed)].join(', '));
