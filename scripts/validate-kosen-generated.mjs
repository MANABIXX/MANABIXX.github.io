import fs from 'node:fs/promises';
import path from 'node:path';

const root = process.cwd();
const sourcePath = path.join(root, 'static/data/kosen-past-exam-sources.json');
const questionsPath = path.join(root, 'static/data/kosen-questions.json');
const mathPath = path.join(root, 'static/data/kosen-math-section-1.json');
const sources = JSON.parse(await fs.readFile(sourcePath, 'utf8'));
const kosen = JSON.parse(await fs.readFile(questionsPath, 'utf8'));
const math = JSON.parse(await fs.readFile(mathPath, 'utf8'));
const expectedYears = [2024, 2025, 2026];
const expectedSubjects = ['math', 'english', 'science', 'social'];

if (JSON.stringify(sources.years) !== JSON.stringify(expectedYears)) {
  throw new Error('高専過去問の対象年度が2024〜2026年になっていません。');
}
for (const subject of expectedSubjects) {
  for (const year of expectedYears) {
    const source = sources.sources.find((item) => item.subject === subject && item.year === year);
    if (!source?.localPath || !source.registryPath) {
      throw new Error('レジストリPDFが不足しています: ' + subject + ' ' + year);
    }
    const prefix = `reg-${subject}-${year}-`;
    const generated = kosen.questions.filter((question) =>
      question.id.startsWith(prefix) && question.sourceYear === year &&
      question.sourceFile === source.localPath);
    if (generated.length === 0) {
      throw new Error('過去問由来の生成問題がありません: ' + subject + ' ' + year);
    }
  }
}
const ids = new Set();
for (const question of kosen.questions) {
  if (ids.has(question.id)) throw new Error('問題IDが重複しています: ' + question.id);
  ids.add(question.id);
  if (!Array.isArray(question.options) || question.options.length !== 4 ||
      !Number.isInteger(question.correct) || question.correct < 0 || question.correct > 3) {
    throw new Error('4択形式が不正です: ' + question.id);
  }
}
const mathIds = new Set(math.questions.map((question) => question.id));
const generatedMath = kosen.questions.filter((question) =>
  question.subject === 'math' && question.id.startsWith('reg-math-'));
for (const question of generatedMath) {
  if (!mathIds.has(question.id)) {
    throw new Error('数学大問1用データへの統合漏れ: ' + question.id);
  }
}
console.log(`高専過去問生成データ OK: ${sources.sources.length} PDFs / ${kosen.questions.length} questions / ${generatedMath.length} generated math questions`);
