import fs from 'node:fs/promises';
import path from 'node:path';

const directory = path.resolve('flutter/assets/fonts');
await fs.mkdir(directory, { recursive: true });
const version = '2.0.0';
const files = [
  ['NotoSansJP-Regular.ttf', 'Regular'],
  ['NotoSansJP-Bold.ttf', 'Bold']
];
for (const [filename, weight] of files) {
  const url = `https://cdn.jsdelivr.net/npm/@reogrid/font-jp@${version}/NotoSansJP-${weight}.ttf`;
  const response = await fetch(url);
  if (!response.ok) throw new Error('Noto Sans JP ' + weight + ' download failed: ' + response.status);
  const font = Buffer.from(await response.arrayBuffer());
  if (font.length < 500_000) throw new Error('Noto Sans JP ' + weight + ' font is unexpectedly small.');
  await fs.writeFile(path.join(directory, filename), font);
}
const licenseResponse = await fetch('https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/OFL.txt');
if (!licenseResponse.ok) throw new Error('Noto Sans JP OFL license download failed: ' + licenseResponse.status);
await fs.writeFile(path.join(directory, 'OFL.txt'), await licenseResponse.text());
console.log('Bundled static Noto Sans JP Regular and Bold TTF faces locally.');
