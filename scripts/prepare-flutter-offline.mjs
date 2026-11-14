import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { FLUTTER_PUBLIC_DATA_FILES } from './flutter-public-data.mjs';

const root = process.cwd();
const dataRoot = path.join(root, 'static', 'data');
const webRoot = path.join(root, 'flutter', 'web');

const hash = createHash('sha256');
const urls = [];
for (const name of FLUTTER_PUBLIC_DATA_FILES) {
  const file = path.join(dataRoot, name);
  const stat = await fs.stat(file).catch(() => null);
  if (!stat?.isFile()) throw new Error(`Required Flutter dataset is missing: static/data/${name}`);
  hash.update(name);
  hash.update(await fs.readFile(file));
  urls.push('/data/' + name);
}
const dataVersion = hash.digest('hex').slice(0, 20);
await fs.writeFile(path.join(webRoot, 'offline-data-manifest.json'), JSON.stringify({ version: dataVersion, files: urls }, null, 2) + '\n');

const template = await fs.readFile(path.join(webRoot, 'flutter-sw.template.js'), 'utf8');
const worker = template.replaceAll('__DATA_VERSION__', dataVersion);
if (worker.includes('__DATA_VERSION__')) throw new Error('Service worker template contains unresolved version placeholders.');
await fs.writeFile(path.join(webRoot, 'flutter-sw.js'), worker);
console.log(`Prepared ${urls.length} approved Flutter datasets (version ${dataVersion}).`);
