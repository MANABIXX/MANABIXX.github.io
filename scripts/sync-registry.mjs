import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const lock=JSON.parse(await fs.readFile(path.join(root,'registry.lock.json'),'utf8'));
const base='https://raw.githubusercontent.com/'+lock.repository+'/'+lock.commit+'/';
const response=await fetch(base+'registry.json');
if(!response.ok)throw new Error('Registry manifest download failed: '+response.status);
const manifest=await response.json();
const selected=new Set(lock.datasets);
const output={'question-bank':'questions.json','public-exam':'public-exam.json','summary-foundation':'summary-foundation.json','summary-assets':'summary-assets.json','knowledge-base':'knowledge-base.json','famous-quotes':'famous-quotes.json','motivation-200':'motivation-200.json','supplementary':'s-exclusive.json','supplementary-beta':'s-exclusive-beta.json','mock-exams':'mock-exams.json','supplementary-en':'private-en.json','supplementary-ja':'private-ja.json','supplementary-ma':'private-ma.json','supplementary-sc':'private-sc.json','supplementary-so':'private-so.json'};
for(const dataset of manifest.datasets){
 if(!selected.has(dataset.id)||dataset.format!=='json')continue;
 const file=await fetch(base+dataset.path);
 if(!file.ok)throw new Error('Dataset download failed: '+dataset.id+' ('+file.status+')');
 const content=await file.text();JSON.parse(content);
 const target=path.join(root,'static','data',output[dataset.id]||dataset.id+'.json');
 await fs.mkdir(path.dirname(target),{recursive:true});await fs.writeFile(target,content+'\n');
 console.log('Synced '+dataset.id+' ('+dataset.recordCount+' records)');
}
console.log('Content registry pinned at '+lock.commit);
