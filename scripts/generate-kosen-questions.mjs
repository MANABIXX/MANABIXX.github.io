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
// 応用レベルの横断問題。計算・文法・実験考察・社会の因果関係を確認する。
questions.push(
  make('reg-math-2026-06','math','応用・二次方程式','高専入試応用','x²−5x＋6＝0 の解はどれか。',['x＝1, 6','x＝2, 3','x＝−2, −3','x＝0, 5'],1,'左辺を (x−2)(x−3) と因数分解する。',2026),
  make('reg-english-2026-06','english','応用・仮定法','高専入試応用','If I (　) you, I would talk to her.',['am','is','were','be'],2,'現在の事実に反する仮定を表す仮定法では、主語がIでもwereを使う。',2026),
  make('reg-science-2026-06','science','応用・濃度変化','高専入試応用','質量パーセント濃度10％の食塩水100gから水を20g蒸発させた。濃度は何％か。',['8％','10％','12.5％','15％'],2,'食塩は10gのまま、溶液は80gになる。10÷80×100＝12.5％。',2026),
  make('reg-social-2026-06','social','応用・経済','高専入試応用','物価が継続的に上昇し、貨幣の価値が下がる現象はどれか。',['デフレーション','インフレーション','景気後退','円高'],1,'物価が継続的に上昇する現象をインフレーションという。',2026),
  { id:'reg-japanese-2026-06', subject:'japanese', topic:'応用・論理展開', level:'高専入試応用', prompt:'文章中の「したがって」が示す関係として最も適切なものはどれか。', options:['前の内容と反対の内容を示す','前の内容から導かれる結論を示す','具体例を追加する','時間の順序を示す'], correct:1, explanation:'「したがって」は、前の内容を受けた結論・結果を示す接続語。', sourceLabel:'独自作成', sourceNote:'国語は今回の過去問レジストリ対象外。' }
);
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
// Add source-linked variants only for topics actually extracted from each PDF.
const registryTemplates = {
  math: {
    '正負の数': ['大問1・正負の数','−8＋13−6 の値はどれか。',['−1','1','5','−27'],0,'−8＋13＝5、5−6＝−1。'],
    '平方根': ['大問1・平方根','√72 を a√2 の形にしたとき、a はいくつか。',['4','5','6','8'],2,'72＝36×2 より √72＝6√2。'],
    '因数分解': ['大問1・因数分解','x²−7x＋12 を因数分解したものはどれか。',['(x−2)(x−6)','(x＋3)(x＋4)','(x−3)(x−4)','(x＋2)(x−6)'],2,'積が12、和が−7となる−3と−4を使う。'],
    '二次方程式': ['大問1・二次方程式','x²−5x＋6＝0 の解はどれか。',['1と6','2と3','−2と−3','0と5'],1,'(x−2)(x−3)＝0 より x＝2,3。'],
    '一次関数': ['大問1・一次関数','y＝3x−2 で x＝4 のとき、y はいくつか。',['8','10','12','14'],1,'y＝3×4−2＝10。'],
    '確率': ['大問1・確率','正六面体のさいころを1回投げる。偶数の目が出る確率はどれか。',['1/3','1/2','2/3','5/6'],1,'偶数は2・4・6の3通り。3/6＝1/2。'],
    '図形': ['大問1・図形','直角をはさむ2辺が6cm、8cmの直角三角形の斜辺は何cmか。',['9','10','12','14'],1,'三平方の定理より √(6²＋8²)＝10cm。']
  },
  english: {
    '関係代名詞': ['文法・関係代名詞','The student (　) came here is my brother.',['which','who','where','when'],1,'人を先行詞とし、後ろで主語になる関係代名詞はwho。'],
    '不定詞': ['文法・不定詞','I decided (　) English every day.',['study','studying','to study','studied'],2,'decide の目的語には to 不定詞を使う。'],
    '比較': ['文法・比較','This problem is (　) than that one.',['difficult','more difficult','most difficult','the difficult'],1,'長い形容詞の比較級は more＋形容詞＋than。'],
    '受け身': ['文法・受け身','This bridge (　) in 1990.',['built','was built','is building','builds'],1,'過去の受け身は was/were＋過去分詞。'],
    '仮定法': ['文法・仮定法','If I (　) you, I would try again.',['am','was','were','be'],2,'現在の事実に反する仮定ではwereを使う。'],
    '現在完了': ['文法・現在完了','She has (　) in Tokyo for five years.',['live','lived','living','lives'],1,'現在完了は have/has＋過去分詞。']
  },
  science: {
    '電流': ['物理・電流','6Vの電圧を3Ωの抵抗に加えた。流れる電流は何Aか。',['1','2','3','18'],1,'I＝V÷R＝6÷3＝2A。'],
    '電圧': ['物理・電圧','4Ωの抵抗に2Aの電流が流れる。電圧は何Vか。',['2','4','6','8'],3,'V＝RI＝4×2＝8V。'],
    '抵抗': ['物理・抵抗','12Vの電圧で3Aの電流が流れる回路の抵抗は何Ωか。',['3','4','9','36'],1,'R＝V÷I＝12÷3＝4Ω。'],
    '中和': ['化学・中和','塩酸と水酸化ナトリウム水溶液が中和すると、主に何ができるか。',['水と酸素','水と塩化ナトリウム','水素と酸素','二酸化炭素と水'],1,'酸とアルカリの中和では水と塩ができる。'],
    '遺伝': ['生物・遺伝','遺伝情報を担う物質として正しいものはどれか。',['デンプン','DNA','脂肪','水'],1,'遺伝情報の基本的な担い手はDNA。'],
    '地震': ['地学・地震','震源から遠くなるほど、一般に初期微動継続時間はどうなるか。',['短くなる','長くなる','変化しない','必ず0秒になる'],1,'P波とS波の到着時刻の差は遠いほど大きくなる。'],
    '天体': ['地学・天体','昼と夜が繰り返される主な原因はどれか。',['地球の公転','地球の自転','月の公転','太陽の自転'],1,'地球の自転によって昼と夜が生じる。'],
    '化学変化': ['化学・化学変化','銅を空気中で十分に加熱したとき、表面にできる黒色の物質はどれか。',['酸化銅','塩化銅','水酸化銅','炭酸銅'],0,'銅が酸素と結びつき、黒色の酸化銅ができる。']
  },
  social: {
    '気候': ['地理・気候','日本海側で冬に雪が多くなりやすい主な理由はどれか。',['季節風が日本海で水蒸気を含むため','太平洋高気圧が強まるため','偏西風が止まるため','海流がなくなるため'],0,'冬の季節風が日本海で水蒸気を含み、山地で雪を降らせる。'],
    '地形図': ['地理・地形図','地形図で等高線の間隔が狭い場所は、一般にどのような地形か。',['傾斜が急','傾斜が緩やか','平ら','必ず谷底'],0,'等高線の間隔が狭いほど急斜面。'],
    '貿易': ['地理・貿易','各国が相対的に生産費用の低い財に特化する考え方はどれか。',['比較優位','人口転換','三権分立','需要曲線'],0,'比較優位に基づく分業は国際貿易の利益を説明する。'],
    '産業': ['地理・産業','小売業や飲食業が分類される産業はどれか。',['第一次産業','第二次産業','第三次産業','第四次産業'],2,'商業・サービス業は第三次産業。'],
    '明治': ['歴史・明治','1871年に藩を廃止して府県を置いた改革はどれか。',['廃藩置県','地租改正','大政奉還','文明開化'],0,'明治政府は1871年に廃藩置県を実施した。'],
    '憲法': ['公民・憲法','日本国憲法の三つの基本原理に含まれないものはどれか。',['国民主権','基本的人権の尊重','平和主義','身分制度の維持'],3,'三つの基本原理は国民主権・基本的人権の尊重・平和主義。'],
    '需要': ['公民・需要','供給量が変わらず需要量が増えた場合、一般に価格はどうなりやすいか。',['上がる','下がる','必ず0円になる','変化しない'],0,'需要が増えれば価格は上がりやすい。'],
    '供給': ['公民・供給','需要量が変わらず供給量が増えた場合、一般に価格はどうなりやすいか。',['上がる','下がる','必ず2倍になる','変化しない'],1,'供給が増えれば価格は下がりやすい。']
  }
};
const topicSlug = (value) => value.normalize('NFKC').replace(/[^a-zA-Z0-9一-龠ぁ-んァ-ヶ]+/g, '-').replace(/^-|-$/g, '');
for (const source of sources.sources) {
  const templates = registryTemplates[source.subject] ?? {};
  for (const hint of source.topicHints ?? []) {
    const template = templates[hint];
    if (!template) continue;
    const [topic, prompt, options, correct, explanation] = template;
    questions.push({
      id: 'registry-' + source.year + '-' + source.subject + '-' + topicSlug(hint),
      subject: source.subject,
      topic,
      level: source.subject === 'math' ? '高専入試・大問1' : '高専入試・過去問分析',
      prompt, options, correct, explanation,
      sourceLabel: '過去問レジストリ分析・オリジナル',
      sourceNote: source.year + '年度の' + ({math:'数学',english:'英語',science:'理科',social:'社会'})[source.subject] + '過去問PDFから「' + hint + '」を抽出し、その分野をもとに新規作成した類題。原文の転載ではありません。',
      sourceYear: source.year,
      sourceFile: source.localPath,
      registryUrl: source.registryUrl
    });
  }
}

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
