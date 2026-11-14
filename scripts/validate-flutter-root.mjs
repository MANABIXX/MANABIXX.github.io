import fs from 'node:fs/promises';
import path from 'node:path';

const root = path.join(process.cwd(), 'flutter', 'build', 'web');
const readJson = async (name) => JSON.parse(await fs.readFile(path.join(root, name), 'utf8'));
const index = await fs.readFile(path.join(root, 'index.html'), 'utf8');
const fallback = await fs.readFile(path.join(root, '404.html'), 'utf8');
const manifest = await readJson('manifest.webmanifest');
const kosenManifest = await readJson('manifest-kosen.webmanifest');
const foundationManifest = await readJson('manifest-foundation.webmanifest');
const offline = await readJson('offline-data-manifest.json');
const app = await readJson('offline-app-manifest.json');
const worker = await fs.readFile(path.join(root, 'flutter-sw.js'), 'utf8');
const routes = await fs.readFile(path.join(process.cwd(), 'flutter', 'lib', 'main.dart'), 'utf8');

if (!index.includes('<base href="/">')) throw new Error('Flutter base href must be /.');
if (fallback !== index) throw new Error('404.html must mirror the Flutter entry point for GitHub Pages deep links.');
for (const [name, item] of [['main', manifest], ['kosen', kosenManifest], ['foundation', foundationManifest]]) {
  if (item.scope !== '/') throw new Error(`${name} PWA manifest must be scoped to /.`);
}
if (manifest.start_url !== '/' || kosenManifest.start_url !== '/practice/kosen' || foundationManifest.start_url !== '/practice/foundation-training') {
  throw new Error('PWA manifest start URLs do not match the clean root routes.');
}
if (!offline.version || !Array.isArray(offline.files) || offline.files.length === 0) {
  throw new Error('Offline data manifest is empty or invalid.');
}
if (!app.version || !Array.isArray(app.files) || app.files.length === 0) {
  throw new Error('Offline app manifest is empty or invalid.');
}
if (worker.includes('__DATA_VERSION__') || worker.includes('__APP_VERSION__')) {
  throw new Error('Service worker has unresolved version placeholders.');
}
if (!index.includes('navigator.serviceWorker.register("/flutter-sw.js"')) {
  throw new Error('Root service worker registration is missing.');
}
if (/<(?:script|link)[^>]+(?:src|href)=["']\/flutter\//i.test(index)) throw new Error('Root app entry point still references /flutter/ assets.');
for (const route of ['/practice/kosen', '/practice/foundation-training', '/records', '/summary']) {
  if (!routes.includes(`'${route}'`)) throw new Error(`Flutter route is missing: ${route}`);
}

async function assertCachedFile(url, label) {
  if (typeof url !== 'string' || !url.startsWith('/') || url.startsWith('//') || url.includes('..')) {
    throw new Error(`Invalid ${label} URL: ${url}`);
  }
  await fs.access(path.join(root, url.slice(1)));
}
for (const url of offline.files) await assertCachedFile(url, 'dataset');
for (const url of app.files) await assertCachedFile(url, 'app asset');
for (const [name, item] of [['main', manifest], ['kosen', kosenManifest], ['foundation', foundationManifest]]) {
  for (const icon of item.icons || []) await assertCachedFile(icon.src, `${name} icon`);
}
for (const url of ['/manifest-kosen.webmanifest', '/manifest-foundation.webmanifest', '/favicon.svg', '/kosen-icon.svg', '/foundation-icon.svg']) {
  if (!app.files.includes(url)) throw new Error(`Offline app manifest is missing ${url}`);
}

if (!app.files.includes('/flutter_bootstrap.js') || !app.files.includes('/index.html')) {
  throw new Error('Offline app manifest does not include the Flutter bootstrap and entry point.');
}
await fs.access(path.join(root, 'assets', 'study-icon.svg'));
console.log(`Root Flutter build validated: ${offline.files.length} datasets, ${app.files.length} app assets, base href /, 404 fallback.`);
