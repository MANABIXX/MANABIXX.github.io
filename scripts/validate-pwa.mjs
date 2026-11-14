import fs from 'node:fs/promises';
import path from 'node:path';

const root = process.cwd();
const manifestPath = path.join(root, 'static', 'manifest.webmanifest');
const manifest = JSON.parse(await fs.readFile(manifestPath, 'utf8'));
const required = ['name', 'short_name', 'start_url', 'scope', 'display', 'icons'];
for (const key of required) {
  if (!(key in manifest)) throw new Error(`PWA manifest is missing: ${key}`);
}
if (!Array.isArray(manifest.icons) || manifest.icons.length === 0) {
  throw new Error('PWA manifest must define at least one icon.');
}
for (const icon of manifest.icons) {
  if (!icon.src || !icon.sizes || !icon.type) {
    throw new Error('Each PWA icon needs src, sizes and type.');
  }
  const iconPath = path.join(root, 'static', icon.src.replace(/^\//, ''));
  await fs.access(iconPath);
}
if (manifest.display !== 'standalone' && manifest.display !== 'fullscreen') {
  throw new Error('Study should be installable as a standalone app.');
}
await fs.access(path.join(root, 'src', 'service-worker.js'));

const flutterWeb = path.join(root, 'flutter', 'web');
for (const [file, start, icon] of [
  ['manifest-kosen.webmanifest', '/flutter/practice/kosen', 'kosen-icon.svg'],
  ['manifest-foundation.webmanifest', '/flutter/practice/foundation-training', 'foundation-icon.svg'],
]) {
  const modeManifest = JSON.parse(await fs.readFile(path.join(flutterWeb, file), 'utf8'));
  if (modeManifest.display !== 'standalone' || modeManifest.start_url !== start ||
      modeManifest.scope !== '/flutter/' || !modeManifest.icons?.some((item) => item.src.endsWith(icon))) {
    throw new Error(`Invalid independent Flutter PWA manifest: ${file}`);
  }
  await fs.access(path.join(flutterWeb, icon));
}
await fs.access(path.join(flutterWeb, 'favicon.svg'));

console.log(`PWA configuration OK: ${manifest.name} plus two independent Flutter mode manifests`);
