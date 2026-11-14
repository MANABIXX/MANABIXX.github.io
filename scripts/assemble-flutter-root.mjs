import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';

const repoRoot = process.cwd();
const output = path.join(repoRoot, 'flutter', 'build', 'web');
const dataSource = path.join(repoRoot, 'static', 'data');
const iconSource = path.join(repoRoot, 'static', 'assets', 'study-icon.svg');

await fs.mkdir(path.join(output, 'data'), { recursive: true });
await fs.mkdir(path.join(output, 'assets'), { recursive: true });
await fs.cp(dataSource, path.join(output, 'data'), { recursive: true, force: true });
await fs.copyFile(iconSource, path.join(output, 'assets', 'study-icon.svg'));
const index = await fs.readFile(path.join(output, 'index.html'));
await fs.writeFile(path.join(output, '404.html'), index);

async function walk(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...await walk(full));
    else if (entry.isFile()) files.push(full);
  }
  return files;
}

const allFiles = (await walk(output)).sort();
const hash = createHash('sha256');
const urls = [];
for (const file of allFiles) {
  const relative = path.relative(output, file).split(path.sep).join('/');
  if (relative === 'offline-app-manifest.json' || relative.startsWith('data/')) continue;
  const bytes = await fs.readFile(file);
  hash.update(relative);
  hash.update(bytes);
  if (relative !== 'flutter-sw.js') urls.push('/' + relative);
}
const version = hash.digest('hex').slice(0, 24);
await fs.writeFile(
  path.join(output, 'offline-app-manifest.json'),
  JSON.stringify({ version, files: urls }, null, 2) + '\n'
);
const workerPath = path.join(output, 'flutter-sw.js');
const worker = await fs.readFile(workerPath, 'utf8');
if (!worker.includes('__APP_VERSION__')) throw new Error('Flutter service worker app-version placeholder missing.');
await fs.writeFile(workerPath, worker.replaceAll('__APP_VERSION__', version));
console.log(`Assembled root Flutter app: ${urls.length} files cached offline (version ${version}).`);
