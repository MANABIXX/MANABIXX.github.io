import fs from 'node:fs/promises';
import path from 'node:path';

const directory = path.resolve('flutter/assets/fonts');
await fs.mkdir(directory, { recursive: true });
const source = 'https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf';
const response = await fetch(source);
if (!response.ok) throw new Error('Noto Sans JP download failed: ' + response.status);
const font = Buffer.from(await response.arrayBuffer());
if (font.length < 1_000_000) throw new Error('Downloaded font is unexpectedly small.');
// Google Fonts distributes Noto Sans JP as a variable TTF (wght 100–900).
// The same local variable face is registered at 400 and 700 in pubspec.yaml.
await fs.writeFile(path.join(directory, 'NotoSansJP-Regular.ttf'), font);
await fs.writeFile(path.join(directory, 'NotoSansJP-Bold.ttf'), font);
const licenseResponse = await fetch('https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/OFL.txt');
if (!licenseResponse.ok) throw new Error('Noto Sans JP OFL license download failed: ' + licenseResponse.status);
await fs.writeFile(path.join(directory, 'OFL.txt'), await licenseResponse.text());
console.log('Bundled local Noto Sans JP variable TTF (' + font.length + ' bytes).');
