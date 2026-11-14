# MANABIXX Flutter Web

Flutter Web is now the production GitHub Pages app and is deployed at the repository root:
https://manabixx.github.io/

The former SvelteKit app remains in the repository for source/reference and compatibility checks; the Pages deployment artifact is the Flutter build.

## Offline behavior

- `npm run prepare:flutter-offline` scans every JSON dataset under `static/data/`, writes a versioned dataset manifest, and generates the service worker source.
- `npm run assemble:flutter-root` copies the complete data directory and app icon into the Flutter output, creates the root `404.html` SPA fallback, and generates a manifest containing every built app resource.
- The service worker pre-caches the app shell, Flutter runtime/assets, and all problem datasets during installation. Once installation has completed, practice screens can load the bundled data while offline.
- Every app launch checks the service worker registration. A changed app/data version installs a new cache before the old cache is removed.
- Where supported by the browser, Periodic Background Sync requests a weekly data refresh. Browsers without that API still refresh on the next app launch. Background execution is controlled by the browser/OS and cannot be guaranteed while the app is closed.

## Production build

Run from the repository root after syncing and generating the data:

```sh
npm install
npm run sync:registry
npm run generate:kosen
npm run validate:kosen
npm run generate:foundation-training
npm run prepare:flutter-offline
npm run fetch:flutter-fonts

cd flutter
flutter pub get
flutter analyze
flutter test
flutter build web --release --wasm --base-href /
cd ..

npm run assemble:flutter-root
npm run validate:flutter-root
```

The Pages workflow runs the same preparation, test, build, assembly, and validation steps and deploys `flutter/build/web` to the site root.

## Routing

Flutter uses path URL strategy. The root `404.html` is an exact copy of the Flutter entry point so GitHub Pages deep links (for example `/practice/kosen` and `/summary/science`) boot Flutter while preserving the requested path.

## Data and progress

Problem JSON remains source-controlled under `static/data/`. Practice history, answer totals, and wrong-question IDs are stored locally per dataset/mode using the browser persistence backend. The offline service worker separately caches all source data and built app resources.
