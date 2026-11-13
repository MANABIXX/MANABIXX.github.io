import fs from 'node:fs/promises';
import path from 'node:path';

const lockPath = path.resolve('registry.lock.json');
const lock = JSON.parse(await fs.readFile(lockPath, 'utf8'));
const response = await fetch(`https://api.github.com/repos/${lock.repository}/commits/main`, {
  headers: {
    accept: 'application/vnd.github+json',
    'x-github-api-version': '2022-11-28',
    ...(process.env.GITHUB_TOKEN ? { authorization: `Bearer ${process.env.GITHUB_TOKEN}` } : {})
  }
});
if (!response.ok) throw new Error(`Could not check content registry: HTTP ${response.status}`);
const latest = await response.json();
if (!/^[a-f0-9]{40}$/.test(latest.sha ?? '')) throw new Error('GitHub returned an invalid registry commit SHA.');
if (latest.sha === lock.commit) {
  console.log(`Content registry is already current: ${lock.commit}`);
} else {
  lock.commit = latest.sha;
  await fs.writeFile(lockPath, JSON.stringify(lock, null, 2) + '\n');
  console.log(`Updated content registry pin: ${latest.sha}`);
}
