import fs from 'node:fs/promises';
import path from 'node:path';

const root = path.join(process.cwd(), 'flutter', 'build', 'web');
const index = await fs.readFile(path.join(root, 'index.html'), 'utf8');
const fallback = await fs.readFile(path.join(root, '404.html'), 'utf8');
const manifest = JSON.parse(await fs.readFile(path.join(root, 'manifest.webmanifest'), 'utf8'));
const offline = JSON.parse(await fs.readFile(path.join(root, 'offline-data-manifest.json'), 'utf8'));

if (!index.includes('<base href="/">')) throw new Error('Flutter base href must be /.');
if (fallback !== index) throw new Error('404.html must mirror the Flutter entry point.');
if (manifest.start_url !== '/' || manifest.scope !== '/') throw new Error('PWA manifest must be scoped to /.');
if (!offline.version || !Array.isArray(offline.files) || offline.files.length === 0) {
  throw new Error('Offline data manifest is empty or invalid.');
}
for (const url of offline.files) {
  const local = path.join(root, url.replace(/^\\//, ''));
  await fs.access(local);
}
await fs.access(path.join(root, 'assets', 'study-icon.svg'));
console.log(`Root Flutter build validated: ${offline.files.length} datasets, base href /, 404 fallback present.`);
