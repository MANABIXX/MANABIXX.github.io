# MANABIXX Next.js learning app

This app lives in `next-app/` so the existing GitHub Pages/SvelteKit site and its legacy pages remain intact.

## Local development
```bash
cd next-app
npm install
npm run dev
```

## Vercel
Import the existing repository and set **Root Directory** to `next-app`. Framework preset: Next.js. Vercel will build this app independently; the existing GitHub Pages site remains available at its current URL.

The MVP uses localStorage only. No account or environment variables are required. Learning records are stored per browser/device.
