import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const questions = [];
const add = (id, subject, topic, prompt, options, correct, explanation) => questions.push({
  id: 'sano-shoo-' + id, subject, topic, level: '合格基礎',
  prompt, options, correct, explanation,
  sourceLabel: '下積み・基礎反復',
  sourceNote: '佐野松桜高校の合格を目標にした学習用オリジナル問題。公式問題の転載ではありません。'
});
[
  ['japanese','漢字','「責任」の読み方はどれか。',['せきにん','せきじん','せっにん','せきねん'],0,'「責任」は「せきにん」と読む。'],
  ['japanese','語句','「簡潔」の意味として正しいものはどれか。',['短く要点がまとまっている','とても複雑である','感情を強く表す','順序が決まっていない'],0,'簡潔は、余分なものがなく短くまとまっていること。'],
  ['japanese','文法','「静かな町」の「静かな」の品詞はどれか。',['動詞','形容詞','形容動詞','副詞'],2,'「静かだ」と活用する形容動詞。'],
  ['japanese','敬語','「先生がおっしゃる」の敬語の種類はどれか。',['謙譲語','尊敬語','丁寧語','美化語'],1,'先生の動作を高める尊敬語。'],
  ['japanese','読解','文章の要点をつかむとき、最初に確認するとよいものはどれか。',['筆者の主張とその理由','登場人物の名前だけ','段落の文字数','難しい漢字だけ'],0,'主張と理由・具体例のつながりを読む。'],
  ['math','正負の数','−7＋12−4 の値はどれか。',['−1','1','5','−23'],1,'−7＋12＝5、5−4＝1。正答は1。'],
  ['math','分数','3/4＋1/8 の値はどれか。',['4/12','5/8','7/8','1'],2,'3/4＝6/8なので、6/8＋1/8＝7/8。'],
  ['math','一次方程式','3x＋5＝20 のとき、x はいくつか。',['3','4','5','6'],2,'3x＝15よりx＝5。'],
  ['math','割合','定価2000円の品物を20％引きで買うと、代金はいくらか。',['400円','1200円','1600円','1800円'],2,'2000×0.8＝1600円。'],
  ['math','図形','底辺6cm、高さ4cmの三角形の面積は何cm²か。',['10','12','20','24'],1,'三角形の面積は底辺×高さ÷2。6×4÷2＝12。'],
  ['english','be動詞','I (　) a student. に入る語はどれか。',['am','is','are','be'],0,'主語Iに対応するbe動詞はam。'],
  ['english','一般動詞','He (　) soccer every Sunday. に入る語はどれか。',['play','plays','playing','played'],1,'三人称単数・現在形なのでplays。'],
  ['english','過去形','Yesterday, we (　) to the park. に入る語はどれか。',['go','goes','went','going'],2,'goの過去形はwent。'],
  ['english','不定詞','I want (　) a doctor. に入る語はどれか。',['be','being','to be','been'],2,'wantの後ろはto不定詞。'],
  ['english','比較','My bag is (　) than yours. に入る語はどれか。',['heavy','heavier','heaviest','more heavy'],1,'短い形容詞heavyの比較級はheavier。'],
  ['science','密度','質量60g、体積20cm³の物体の密度は何g/cm³か。',['2','3','4','6'],1,'密度＝質量÷体積＝60÷20＝3。'],
  ['science','植物','植物が光合成を行うとき、主に取り入れる気体はどれか。',['酸素','二酸化炭素','窒素','水素'],1,'光合成では二酸化炭素と水から養分をつくり、酸素を放出する。'],
  ['science','電流','電圧6V、抵抗3Ωの回路に流れる電流は何Aか。',['1','2','3','18'],1,'オームの法則よりI＝V÷R＝6÷3＝2A。'],
  ['science','化学','青色リトマス紙を赤色に変える水溶液はどれか。',['酸性','中性','アルカリ性','純水'],0,'酸性の水溶液は青色リトマス紙を赤色に変える。'],
  ['science','地学','昼と夜がくり返される主な原因はどれか。',['地球の公転','地球の自転','月の公転','太陽の自転'],1,'地球が自転しているため昼と夜が生じる。'],
  ['social','地理','日本で最も面積が大きい都道府県はどこか。',['岩手県','長野県','北海道','福島県'],2,'北海道が最も面積の大きい都道府県。'],
  ['social','地理','日本の標準時子午線が通る兵庫県の市はどこか。',['神戸市','明石市','姫路市','西宮市'],1,'東経135度の子午線は兵庫県明石市を通る。'],
  ['social','歴史','鎌倉幕府を開いた人物は誰か。',['源頼朝','足利尊氏','徳川家康','聖徳太子'],0,'源頼朝が鎌倉幕府を開いた。'],
  ['social','歴史','江戸幕府を開いた人物は誰か。',['織田信長','豊臣秀吉','徳川家康','徳川吉宗'],2,'徳川家康が1603年に江戸幕府を開いた。'],
  ['social','公民','日本国憲法の三つの基本原理に含まれないものはどれか。',['国民主権','基本的人権の尊重','平和主義','身分制度の維持'],3,'三つの基本原理は国民主権・基本的人権の尊重・平和主義。']
].forEach((row, index) => add(String(index+1).padStart(2,'0'), ...row));
for (const q of questions) {
  if (q.options.length !== 4 || q.correct < 0 || q.correct > 3) throw new Error('Invalid foundation question: ' + q.id);
}
await fs.writeFile(path.join(root, 'static/data/foundation-training.json'),
  JSON.stringify({ title: '下積みモード', target: '佐野松桜高校 合格基礎', reviewPolicy: '間違えた問題を復習キューへ戻す', questions }, null, 2) + '\n');
console.log('Generated ' + questions.length + ' five-subject foundation-training questions.');
