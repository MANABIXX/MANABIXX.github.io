import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';

const root = process.cwd();
const dataRoot = path.join(root, 'static', 'data');
const webRoot = path.join(root, 'flutter', 'web');

async function walk(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...await walk(full));
    else if (entry.isFile() && entry.name.toLowerCase().endsWith('.json')) files.push(full);
  }
  return files;
}

const paths = (await walk(dataRoot)).sort();
if (!paths.length) throw new Error('No JSON learning datasets found in static/data.');

const hash = createHash('sha256');
const urls = [];
for (const file of paths) {
  const relative = path.relative(dataRoot, file).split(path.sep).join('/');
  hash.update(relative);
  hash.update(await fs.readFile(file));
  urls.push('/data/' + relative);
}
const version = hash.digest('hex').slice(0, 20);
await fs.writeFile(
  path.join(webRoot, 'offline-data-manifest.json'),
  JSON.stringify({ version, files: urls }, null, 2) + '\n'
);

const template = await fs.readFile(path.join(webRoot, 'flutter-sw.template.js'), 'utf8');
await fs.writeFile(
  path.join(webRoot, 'flutter-sw.js'),
  template.replaceAll('__DATA_VERSION__', version)
);
console.log(`Prepared ${urls.length} offline datasets (version ${version}).`);
