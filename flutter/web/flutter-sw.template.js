const DATA_VERSION = '__DATA_VERSION__';
const CACHE_PREFIX = 'manabixx-offline-';
const CACHE_NAME = CACHE_PREFIX + DATA_VERSION;
const DATA_MANIFEST = '/offline-data-manifest.json';
const APP_SHELL = ['/', '/index.html', '/404.html', '/manifest.webmanifest', DATA_MANIFEST, '/assets/study-icon.svg'];

async function fetchInto(cache, url) {
  const response = await fetch(url, { cache: 'no-store' });
  if (!response.ok) throw new Error('Offline asset fetch failed: ' + url + ' (' + response.status + ')');
  await cache.put(url, response.clone());
}

async function syncAllData(cache) {
  const response = await fetch(DATA_MANIFEST, { cache: 'no-store' });
  if (!response.ok) throw new Error('Offline manifest unavailable: ' + response.status);
  const manifest = await response.json();
  if (!Array.isArray(manifest.files) || manifest.files.length === 0) {
    throw new Error('Offline manifest contains no datasets.');
  }
  await cache.put(DATA_MANIFEST, response.clone());
  await Promise.all(manifest.files.map((url) => fetchInto(cache, url)));
}

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await Promise.all(APP_SHELL.map((url) => fetchInto(cache, url)));
    await syncAllData(cache);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys
      .filter((key) => key.startsWith(CACHE_PREFIX) && key !== CACHE_NAME)
      .map((key) => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        const response = await fetch(request);
        if (response.ok) {
          const cache = await caches.open(CACHE_NAME);
          await cache.put(request, response.clone());
        }
        return response;
      } catch (_) {
        return (await caches.match(request)) || (await caches.match('/index.html')) || (await caches.match('/'));
      }
    })());
    return;
  }

  event.respondWith((async () => {
    const cached = await caches.match(request);
    if (cached) return cached;
    const response = await fetch(request);
    if (response.ok && response.type === 'basic') {
      const cache = await caches.open(CACHE_NAME);
      await cache.put(request, response.clone());
    }
    return response;
  })());
});

self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'manabixx-weekly-data-sync') {
    event.waitUntil((async () => {
      const cache = await caches.open(CACHE_NAME);
      await syncAllData(cache);
    })());
  }
});
