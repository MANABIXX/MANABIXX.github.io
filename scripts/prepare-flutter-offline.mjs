import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { flutterOfflineDatasets } from './flutter-offline-data.mjs';

const root = process.cwd();
const dataRoot = path.join(root, 'static', 'data');
const webRoot = path.join(root, 'flutter', 'web');
const hash = createHash('sha256');
const urls = [];

for (const filename of flutterOfflineDatasets) {
  const file = path.join(dataRoot, filename);
  const content = await fs.readFile(file);
  hash.update(filename);
  hash.update('\0');
  hash.update(content);
  urls.push('/data/' + filename);
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
console.log(`Prepared ${urls.length} Flutter datasets (version ${version}); non-Flutter/private datasets excluded.`);
