import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const lock = JSON.parse(await fs.readFile(path.join(root, 'registry.lock.json'), 'utf8'));
const base = 'https://raw.githubusercontent.com/' + lock.repository + '/' + lock.commit + '/';
const response = await fetch(base + 'registry.json');
if (!response.ok) throw new Error('Registry manifest download failed: ' + response.status);
const manifest = await response.json();
const selected = new Set(lock.datasets);
const output = {
  'question-bank': 'questions.json', 'public-exam': 'public-exam.json',
  'summary-foundation': 'summary-foundation.json', 'summary-assets': 'summary-assets.json',
  'knowledge-base': 'knowledge-base.json', 'famous-quotes': 'famous-quotes.json',
  'motivation-200': 'motivation-200.json', 'supplementary': 's-exclusive.json',
  'supplementary-beta': 's-exclusive-beta.json', 'mock-exams': 'mock-exams.json',
  'supplementary-en': 'private-en.json', 'supplementary-ja': 'private-ja.json',
  'supplementary-ma': 'private-ma.json', 'supplementary-sc': 'private-sc.json',
  'supplementary-so': 'private-so.json'
};
for (const dataset of manifest.datasets) {
  if (!selected.has(dataset.id) || dataset.format !== 'json') continue;
  const file = await fetch(base + dataset.path.split('/').map(encodeURIComponent).join('/'));
  if (!file.ok) throw new Error('Dataset download failed: ' + dataset.id + ' (' + file.status + ')');
  const content = await file.text();
  JSON.parse(content);
  const target = path.join(root, 'static', 'data', output[dataset.id] || dataset.id + '.json');
  await fs.mkdir(path.dirname(target), { recursive: true });
  await fs.writeFile(target, content + '\n');
  console.log('Synced ' + dataset.id + ' (' + dataset.recordCount + ' records)');
}

// The three-year Kosen archive is stored as source PDFs in the registry rather
// than as a normalized JSON dataset. Keep the original papers and their provenance
// available to the Flutter practice generator without copying question text.
const kosenFiles = [
  ['02_2024_syakai_monndai2.pdf', 2024, 'social'],
  ['02_2025_syakai_mondai (1).pdf', 2025, 'social'],
  ['02_2026_syakai_mondai2 (1).pdf', 2026, 'social'],
  ['03_2024_sugaku_mondai.pdf', 2024, 'math'],
  ['03_2025_sugaku_mondai (1).pdf', 2025, 'math'],
  ['03_2026_sugaku_mondai (1).pdf', 2026, 'math'],
  ['04_2024_rika_mondai.pdf', 2024, 'science'],
  ['04_2025_rika_mondai (1).pdf', 2025, 'science'],
  ['04_2026_rika_mondai (1).pdf', 2026, 'science'],
  ['05_2024_eigo_mondai.pdf', 2024, 'english'],
  ['05_2025_eigo_mondai.pdf', 2025, 'english'],
  ['05_2026_eigo_mondai.pdf', 2026, 'english']
];
const kosenRoot = '高専過去問三年分国語以外';
const sources = [];
for (const [filename, year, subject] of kosenFiles) {
  const registryPath = kosenRoot + '/' + filename;
  const url = base + registryPath.split('/').map(encodeURIComponent).join('/');
  const targetName = year + '-' + subject + '.pdf';
  const target = path.join(root, 'static', 'data', 'kosen-past-papers', targetName);
  const file = await fetch(url);
  if (!file.ok) throw new Error('Kosen past paper download failed: ' + registryPath + ' (' + file.status + ')');
  await fs.mkdir(path.dirname(target), { recursive: true });
  await fs.writeFile(target, Buffer.from(await file.arrayBuffer()));
  sources.push({
    year, subject, filename: targetName,
    registryPath, localPath: '/data/kosen-past-papers/' + targetName,
    registryUrl: 'https://github.com/MANABIXX/content-registry/blob/' + lock.commit + '/' +
      registryPath.split('/').map(encodeURIComponent).join('/')
  });
  console.log('Synced Kosen source: ' + year + ' ' + subject);
}
if (selected.has('kosen-past-exams')) {
  await fs.writeFile(path.join(root, 'static', 'data', 'kosen-past-exam-sources.json'),
    JSON.stringify({ registryCommit: lock.commit, years: [2024, 2025, 2026], subjects: ['math', 'english', 'science', 'social'], sources }, null, 2) + '\n');
}
console.log('Content registry pinned at ' + lock.commit);
