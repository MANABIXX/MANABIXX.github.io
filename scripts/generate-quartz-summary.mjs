import fs from "node:fs/promises";
import path from "node:path";
const root=process.cwd(), out=path.resolve(process.argv[2]||"quartz-src/content");
const db=JSON.parse(await fs.readFile(path.join(root,"data/knowledge-base.json"),"utf8"));
const assets=JSON.parse(await fs.readFile(path.join(root,"data/summary-assets.json"),"utf8"));
await fs.rm(out,{recursive:true,force:true}); await fs.mkdir(out,{recursive:true});
const s=v=>String(v??"").trim(), q=v=>JSON.stringify(s(v));
const safe=v=>s(v).replaceAll("/","-").replaceAll("\\","-").replaceAll(":","-").replaceAll("*","-").replaceAll("?","-").replaceAll("<","-").replaceAll(">","-").replaceAll("|","-").replace(/\s+/g,"-").slice(0,80)||"item";
const put=async(p,c)=>{const f=path.join(out,p);await fs.mkdir(path.dirname(f),{recursive:true});await fs.writeFile(f,c.trim()+"\n")};
const bullets=(h,a)=>Array.isArray(a)&&a.length?"\n## "+h+"\n\n"+a.filter(Boolean).map(x=>"- "+s(x)).join("\n")+"\n":"";
const termTable=a=>{if(!Array.isArray(a)||!a.length)return "";const rows=a.map(x=>Array.isArray(x)?x:[x.term,x.definition]).filter(x=>x[0]&&x[1]);return rows.length?"\n## 重要語句\n\n| 用語 | 意味 |\n|---|---|\n"+rows.map(x=>"| "+s(x[0]).replaceAll("|","\\\\|")+" | "+s(x[1]).replaceAll("|","\\\\|")+" |").join("\n")+"\n":""};
const records=[...(db.topicRecords||[]),...(db.authoredModules||[])], groups={};
const fld=r=>{const f=s(r.field);if(f.includes("物理"))return "physics";if(f.includes("化学"))return "chemistry";if(f.includes("生物"))return "biology";if(f.includes("地学")||f.includes("地球"))return "earth";if(f.includes("地理"))return "geography";if(f.includes("歴史"))return "history";if(f.includes("公民"))return "civics";return r.subject==="social"?"social-other":"science-other"};
for(let i=0;i<records.length;i++){const r=records[i];if(!r?.id)continue;const sub=r.subject==="social"?"social":"science",field=fld(r),key=sub+"/"+field;(groups[key]??=[]).push({...r,sub,field,slug:"topic-"+String(i+1).padStart(3,"0")+"-"+safe(r.id)});}
let count=0;
for(const [folder,items] of Object.entries(groups)){const first=items[0],label=first.field==="physics"?"物理":first.field==="chemistry"?"化学":first.field==="biology"?"生物":first.field==="earth"?"地学":first.field==="geography"?"地理":first.field==="history"?"歴史":first.field==="civics"?"公民":"その他";
await put(folder+"/index.md","---\ntitle: "+q(label)+"\ndescription: "+q(label+"の学習項目")+"\n---\n# "+label+"\n\n"+items.map(r=>"- [["+r.slug+"|"+s(r.title||r.id)+"]]").join("\n"));
for(const r of items){const status=r.status==="authored"?"解説あり":"基礎項目";let body="---\ntitle: "+q(r.title||r.id)+"\ndescription: "+q(r.explanation||r.title||r.id)+"\ntags:\n  - "+(r.sub==="science"?"理科":"社会")+"\n  - "+label+"\n  - "+status+"\n---\n# "+s(r.title||r.id)+"\n\n> 対象："+(r.grade?"中学"+r.grade+"年":"学年共通")+" / "+status+"\n";
body+=r.explanation?"\n## 要点\n\n"+s(r.explanation)+"\n":"\n> 解説準備中の項目です。登録済みの学習範囲をもとに、内容を順次追加します。\n";
body+=termTable(r.keyTerms||r.terms)+bullets("まず押さえること",r.corePoints||r.targets)+bullets("公式・関係",r.formulas||(r.formula?[r.formula]:[]))+bullets("実験・方法",r.experimentOrMethod)+bullets("よくある間違い",r.commonErrors||r.errors)+bullets("入試での問われ方",r.questionPatterns||r.questions)+bullets("図で確認する内容",r.diagrams);
if(r.example)body+="\n## 例題\n\n"+s(r.example.q)+"\n\n"+(r.example.work||[]).map((x,i)=>(i+1)+". "+x).join("\n")+"\n\n**答え：** "+s(r.example.a)+"\n";
if(r.sourceUrl)body+="\n## 参考資料\n\n["+r.sourceUrl+"]("+r.sourceUrl+")\n";
body+="\n[分野一覧へ戻る](./index)";await put(folder+"/"+r.slug+".md",body);count++;}}
const res=assets.resources||[];
await put("resources/index.md","---\ntitle: 図解・比較表\ndescription: 理科・社会の図解と比較表\n---\n# 図解・比較表\n\n"+res.map((r,i)=>"- [[resource-"+String(i+1).padStart(3,"0")+"|"+s(r.title||r.id)+"]]").join("\n"));
for(let i=0;i<res.length;i++){const r=res[i],title=s(r.title||r.id||"資料");let b="---\ntitle: "+q(title)+"\ndescription: "+q(r.subtitle||r.note||title)+"\n---\n# "+title+"\n\n"+s(r.subtitle)+"\n\n"+s(r.note)+"\n";if(Array.isArray(r.nodes))b+="\n## 流れ・構成\n\n"+r.nodes.map((x,j)=>(j+1)+". "+x).join("\n");if(Array.isArray(r.rows))b+="\n\n## 比較\n\n"+r.rows.map(x=>Array.isArray(x)?x.join(" | "):JSON.stringify(x)).join("\n\n");await put("resources/resource-"+String(i+1).padStart(3,"0")+".md",b);}
await put("index.md","---\ntitle: MANABIXX 要点まとめ\ndescription: 理科・社会の要点を分野別に整理した学習ライブラリ\n---\n# MANABIXX 要点まとめ\n\n理科・社会の重要事項を分野ごとに整理。検索、関連ページ、知識グラフで理解をつなげます。\n\n## 科目\n\n- [[science/index|理科]]\n- [[social/index|社会]]\n- [[resources/index|図解・比較表]]\n\n## 収録データ\n\n- 分野レコード："+(db.topicRecords||[]).length+"件\n- 詳細解説："+(db.authoredModules||[]).length+"件\n- 図解・比較表："+res.length+"件\n\n「解説あり」と「基礎項目」を区別し、未完成項目を完成済みとして扱いません。\n\n[MANABIXXの演習・復習へ](https://manabixx.github.io/)");
for(const sub of ["science","social"]){const fields=Object.keys(groups).filter(k=>k.startsWith(sub+"/"));await put(sub+"/index.md","---\ntitle: "+(sub==="science"?"理科":"社会")+"\n---\n# "+(sub==="science"?"理科":"社会")+"\n\n"+fields.map(k=>"- [["+k.split("/")[1]+"/index|"+k.split("/")[1]+"]]").join("\n"));}
console.log("Generated "+count+" knowledge pages and "+res.length+" resource pages.");