import fs from 'node:fs/promises';
import path from 'node:path';

const root = process.cwd();
const manifests = [
  { file: 'static/manifest.webmanifest', publicBase: 'https://manabixx.github.io/' },
  { file: 'flutter/web/manifest.webmanifest', publicBase: 'https://manabixx.github.io/flutter/' },
  { file: 'flutter/web/kosen.webmanifest', publicBase: 'https://manabixx.github.io/flutter/' },
  { file: 'flutter/web/training.webmanifest', publicBase: 'https://manabixx.github.io/flutter/' },
];

for (const entry of manifests) {
  const manifest = JSON.parse(await fs.readFile(path.join(root, entry.file), 'utf8'));
  const required = ['name', 'short_name', 'start_url', 'scope', 'display', 'icons'];
  for (const key of required) {
    if (!(key in manifest)) throw new Error(entry.file + ' is missing: ' + key);
  }
  if (!Array.isArray(manifest.icons) || manifest.icons.length === 0) {
    throw new Error(entry.file + ' must define at least one icon.');
  }
  const scope = new URL(manifest.scope, entry.publicBase);
  const start = new URL(manifest.start_url, entry.publicBase);
  if (start.origin !== scope.origin || !start.pathname.startsWith(scope.pathname)) {
    throw new Error(entry.file + ' start_url must remain inside its scope.');
  }
  for (const icon of manifest.icons) {
    if (!icon.src || !icon.sizes || !icon.type) {
      throw new Error(entry.file + ' icons need src, sizes and type.');
    }
    const iconUrl = new URL(icon.src, new URL(entry.file.split('/').pop(), entry.publicBase));
    const iconPath = path.join(root, 'static', iconUrl.pathname.replace(/^\\//, ''));
    await fs.access(iconPath);
  }
  if (manifest.display !== 'standalone' && manifest.display !== 'fullscreen') {
    throw new Error(entry.file + ' should launch as a standalone app.');
  }
  console.log('PWA manifest OK: ' + manifest.name);
}
await fs.access(path.join(root, 'src', 'service-worker.js'));
console.log('PWA service worker OK.');
