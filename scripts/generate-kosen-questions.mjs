import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const sourcePath = path.join(root, 'static/data/kosen-past-exam-sources.json');
const sources = JSON.parse(await fs.readFile(sourcePath, 'utf8'));
const years = sources.years;
const sourceFor = (subject, year = years[years.length - 1]) =>
  sources.sources.find((item) => item.subject === subject && item.year === year);
const make = (id, subject, topic, level, prompt, options, correct, explanation, year) => {
  const source = sourceFor(subject, year);
  const hints = source?.topicHints ?? [];
  return {
    id, subject, topic, level, prompt, options, correct, explanation,
    sourceLabel: '過去問資料参照・オリジナル',
    sourceNote: `${year}年度の${({math:'数学',english:'英語',science:'理科',social:'社会',japanese:'国語'})[subject]}PDFを取り込み、${hints.length ? '抽出した分野語句：' + hints.slice(0, 4).join('・') : '出題形式'}を参考に設問・選択肢を新規作成。`,
    sourceYear: year,
    sourceFile: source?.localPath ?? ''
  };
};
const questions = [];
// 数学・大問1を意識した計算、小問集合。各年度に数値を変えた類題を作る。
for (const [i, year] of years.entries()) {
  const n = [3, 4, 5][i];
  const signed = -(n+4) + n*3 - (n+1);
  const signedOptions = [signed, signed+2, signed-2, signed+4].map(String);
  const functionValue = -2*n + (n+5);
  const functionOptions = [functionValue-2,functionValue-1,functionValue,functionValue+1].map(String);
  questions.push(
    make(`reg-math-${year}-01`,'math','大問1・正負の数','高専入試基礎',`−${n+4}＋${n*3}−${n+1} の値はどれか。`,signedOptions,0,'負の数を含む加減は、符号を保って左から順に計算する。',year),
    make(`reg-math-${year}-02`,'math','大問1・平方根','高専入試基礎',`√${(n* n)*2} を a√2 と表すとき、a はいくつか。`,[String(n-1),String(n),String(n+1),String(n*2)],1,`${n}²×2 の平方根なので ${n}√2。`,year),
    make(`reg-math-${year}-03`,'math','大問1・一次方程式','高専入試基礎',`${n+1}x−${n}＝${(n+1)*3-n} のとき、x はいくつか。`,['2','3','4','5'],1,'移項して定数項をまとめ、xの係数で割る。',year),
    make(`reg-math-${year}-04`,'math','大問1・因数分解','高専入試標準',`x²＋${2*n+3}x＋${(n+1)*(n+2)} を因数分解したものはどれか。`,[`(x+${n})(x+${n+3})`,`(x+${n+1})(x+${n+2})`,`(x-${n+1})(x-${n+2})`,`(x+${n+2})²`],1,'積が定数項、和がxの係数になる2数を探す。',year),
    make(`reg-math-${year}-05`,'math','大問1・関数','高専入試標準',`y＝−2x＋${n+5} で x＝${n} のとき、y はいくつか。`,functionOptions,functionOptions.indexOf(String(functionValue)),'xの値を代入すると y＝−2×x＋定数。',year)
  );
}
// 英語：文法・語法・会話・読解の4択。
const english = [
  ['文法・受け身','This picture (　) by my sister yesterday.',['draw','drew','was drawn','is drawing'],2,'過去の受け身は was/were＋過去分詞。'],
  ['文法・関係代名詞','The girl (　) lives next door is a tennis player.',['which','who','where','when'],1,'先行詞が人で、後ろが動詞 lives なので主格 who。'],
  ['文法・不定詞','I decided (　) a new language this year.',['study','studying','to study','studied'],2,'decide の後ろは to 不定詞。'],
  ['読解・指示語','英文中の they が何を指すか判断するとき、最も適切なのはどれか。',['前後の文脈から複数の人・物を探す','必ず直前の動詞を指す','文末の単語を指す','主語とは無関係に決める'],0,'代名詞は数・意味・前後の文脈を合わせて判断する。'],
  ['文法・比較','This book is (　) than that one.',['interesting','more interesting','most interesting','the interesting'],1,'長い形容詞の比較級は more＋形容詞＋than。']
];
for (const [i, year] of years.entries()) {
  const start = i * 2;
  const end = i === years.length - 1 ? english.length : start + 2;
  for (let j=start;j<end;j++) { const q=english[j]; questions.push(make(`reg-english-${year}-${String(j+1).padStart(2,'0')}`,'english',q[0],j===3?'高専入試標準':'高専入試基礎',q[1],q[2],q[3],q[4],year)); }
}
// 理科：実験・計算・現象の理解を中心にする。
const science = [
  ['物理・電流','抵抗器に 6V の電圧を加えたところ、電流は 0.5A だった。抵抗は何Ωか。',['3','6','12','30'],2,'オームの法則より R＝V÷I＝6÷0.5＝12Ω。'],
  ['化学・質量パーセント濃度','食塩 12g を水 108g に溶かした。質量パーセント濃度は何％か。',['10','11','12','20'],0,'溶液は120g。12÷120×100＝10％。'],
  ['生物・遺伝','遺伝子の本体として正しいものはどれか。',['RNAだけ','DNA','デンプン','タンパク質だけ'],1,'遺伝情報を担う基本的な物質はDNA。'],
  ['地学・地震','震源からの距離が大きくなるほど、一般に初期微動継続時間はどうなるか。',['短くなる','長くなる','常に一定','0になる'],1,'P波とS波の到着時刻の差は震源から遠いほど大きくなる。'],
  ['化学・中和','塩酸と水酸化ナトリウム水溶液が中和するとき、主にできるものの組合せはどれか。',['水と酸素','水と塩化ナトリウム','水素と酸素','二酸化炭素と水'],1,'酸とアルカリの中和で水と塩ができる。']
];
for (const [i, year] of years.entries()) {
  const start = i * 2;
  const end = i === years.length - 1 ? science.length : start + 2;
  for (let j=start;j<end;j++){const q=science[j];questions.push(make(`reg-science-${year}-${String(j+1).padStart(2,'0')}`,'science',q[0],j===0||j===1?'高専入試標準':'高専入試基礎',q[1],q[2],q[3],q[4],year));}
}
// 社会：地理・歴史・公民を横断。
const social = [
  ['地理・気候','日本海側の冬に降雪が多くなりやすい主な理由はどれか。',['季節風が日本海で水蒸気を含むため','偏西風が一年中止まるため','海流がすべて北向きのため','太平洋高気圧が強まるため'],0,'冬の季節風が日本海を渡る間に水蒸気を含み、山地で雪を降らせる。'],
  ['歴史・近代','明治政府が近代的な中央集権国家をつくるため、1871年に行った改革はどれか。',['廃藩置県','地租改正','大政奉還','版籍奉還'],0,'1871年、藩を廃止して府県を置く廃藩置県を実施した。'],
  ['公民・三権分立','国会の主な役割として正しいものはどれか。',['法律を制定する','裁判を行う','行政を指揮する','条約の違憲性を最終判断する'],0,'国会は国権の最高機関であり、唯一の立法機関。'],
  ['公民・市場経済','需要量が増え、供給量が変わらない場合、一般に市場価格はどうなりやすいか。',['上がる','下がる','必ず0円になる','必ず変わらない'],0,'需要が供給を上回る方向に働くと価格は上昇しやすい。'],
  ['地理・貿易','ある国が他国に比べて相対的に低い費用で生産できる財に特化する考え方はどれか。',['比較優位','人口転換','三権分立','地産地消'],0,'比較優位に基づく分業は国際貿易の利益を説明する。']
];
for (const [i, year] of years.entries()) {
  const start = i * 2;
  const end = i === years.length - 1 ? social.length : start + 2;
  for (let j=start;j<end;j++){const q=social[j];questions.push(make(`reg-social-${year}-${String(j+1).padStart(2,'0')}`,'social',q[0],j===2||j===3?'高専入試標準':'高専入試基礎',q[1],q[2],q[3],q[4],year));}
}
// 国語はレジストリの対象外のため、独自の基礎確認問題として収録。
const japanese = [
  ['漢字','「抽象」の読み方として正しいものはどれか。',['ちゅうしょう','ちゅうぞう','ぬきしょう','ちゅうそう'],0,'「抽象」は「ちゅうしょう」と読む。'],
  ['文法','「静かな」の品詞として正しいものはどれか。',['動詞','形容詞','形容動詞','副詞'],2,'「静かだ」と活用するので形容動詞。'],
  ['敬語','「先生がおっしゃった」の敬語の種類はどれか。',['尊敬語','謙譲語','丁寧語','美化語'],0,'動作主である先生を高める尊敬語。'],
  ['読解','筆者の主張を読み取るとき、最も適切な方法はどれか。',['結論と理由の対応を確認する','最初の一文だけで決める','例だけを抜き出す','接続語を無視する'],0,'結論を支える理由・具体例とのつながりを追う。'],
  ['語彙','「懸念」の意味として最も近いものはどれか。',['心配','感謝','納得','期待'],0,'懸念は、気にかかって不安に思うこと。']
];
for (let j=0;j<japanese.length;j++){const q=japanese[j];questions.push({id:`reg-japanese-001-${String(j+1).padStart(2,'0')}`,subject:'japanese',topic:q[0],level:'高専入試基礎',prompt:q[1],options:q[2],correct:q[3],explanation:q[4],sourceLabel:'独自作成',sourceNote:'国語は今回の過去問レジストリ対象外。基礎確認用のオリジナル問題。'});}
const unique = new Map(questions.map((q)=>[q.id,q]));
const result = { title:'高専入試対策・5教科オリジナル演習', generatedAt:new Date().toISOString(), registryCommit:sources.registryCommit, questionPolicy:'過去問PDFそのものの転載ではなく、出題形式と抽出した分野語句を参考に新規作成した4択問題。', questions:[...unique.values()] };
const kosenPath = path.join(root, 'static/data/kosen-questions.json');
const existingKosen = JSON.parse(await fs.readFile(kosenPath, 'utf8'));
const mergedKosen = new Map([...(existingKosen.questions ?? []), ...result.questions].map((question) => [question.id, question]));
const finalResult = { ...result, questions: [...mergedKosen.values()] };
for (const q of finalResult.questions) if(q.options.length!==4||q.correct<0||q.correct>3) throw new Error('Invalid generated question: '+q.id);
await fs.writeFile(kosenPath,JSON.stringify(finalResult,null,2)+'\n');
const mathPath = path.join(root, 'static/data/kosen-math-section-1.json');
const existingMath = JSON.parse(await fs.readFile(mathPath, 'utf8'));
const mathQuestions = [...(existingMath.questions ?? []), ...finalResult.questions.filter((question) => question.subject === 'math')];
const mathById = new Map(mathQuestions.map((question) => [question.id, question]));
await fs.writeFile(mathPath, JSON.stringify({ title: '高専数学・大問1集中演習', registryCommit: sources.registryCommit, questions: [...mathById.values()] }, null, 2) + '\n');
console.log('Generated '+finalResult.questions.length+' Kosen practice questions and '+mathById.size+' math-section-1 questions.');
