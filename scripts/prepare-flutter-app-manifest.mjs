import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';

const root = path.join(process.cwd(), 'flutter', 'build', 'web');
const hash = createHash('sha256');
const files = [];

async function walk(dir, prefix = '') {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
    const absolute = path.join(dir, entry.name);
    const relative = prefix ? prefix + '/' + entry.name : entry.name;
    if (entry.isDirectory()) {
      await walk(absolute, relative);
    } else if (
      entry.isFile() &&
      relative !== 'offline-app-manifest.json' &&
      relative !== 'flutter-sw.js' &&
      !relative.startsWith('data/')
    ) {
      const bytes = await fs.readFile(absolute);
      hash.update(relative);
      hash.update(bytes);
      files.push('/' + relative);
    }
  }
}

await walk(root);
if (!files.includes('/index.html') || !files.includes('/flutter_bootstrap.js')) {
  throw new Error('Flutter app shell is incomplete; index.html or flutter_bootstrap.js is missing.');
}
const version = hash.digest('hex').slice(0, 20);
await fs.writeFile(
  path.join(root, 'offline-app-manifest.json'),
  JSON.stringify({ version, files }, null, 2) + '\n'
);
console.log(`Prepared ${files.length} offline app assets (version ${version}).`);
