import 'package:material_ui/material_ui.dart';

const _orange = Color(0xFFFF7900);
const _panel = Color(0xFF222226);

class FoundationRoadmapPage extends StatelessWidget {
  const FoundationRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('合格マップ'),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
      children: [
        const Text('YOUR ROUTE', style: TextStyle(color: _orange, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('合格までの道筋を、\n今日やることに分ける。', style: TextStyle(fontSize: 26, height: 1.35, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        const Text('入試方式・学科・コースで試験科目や評価方法は変わります。ここでは2027年度の公開情報と、日々の学習優先順位を分けて表示します。', style: TextStyle(color: Colors.white70, height: 1.6)),
        const SizedBox(height: 22),
        _schoolCard(
          context,
          title: '青藍泰斗高校',
          label: '私立 · コース別に対策',
          summary: '2027年度の募集情報では、一般入試の科目はコース等により国・数・英の3科、または国・数・英・理・社の5科に分かれます。合否は試験点だけでなく調査書等も含めて総合判定。',
          steps: const [
            _RoadStep('01', '国語・数学・英語', 'まずは3教科の基礎を毎日。計算・語彙・文法・読解を短時間で反復。', '最優先'),
            _RoadStep('02', '理科・社会', '5教科型のコースを受験する場合は、用語暗記だけでなく資料・グラフ問題も練習。', '受験コース確認'),
            _RoadStep('03', '過去のミスを解き直す', '間違えた問題を翌日・週末にもう一度。正解しただけで終わらせない。', '毎日'),
          ],
          source: '公式入試情報： https://www.seirantaito.ed.jp/entrance.html',
          footnote: '3科・5科のどちらかは志望コースと年度の募集要項で必ず確認してください。',
        ),
        const SizedBox(height: 16),
        _schoolCard(
          context,
          title: '佐野松桜高校',
          label: '県立 · 5教科＋調査書',
          summary: '2027年度一般選抜は国・数・英・社・理の5教科。学校公表資料では学力検査500点、調査書270点。特色選抜では学校独自検査も実施されます。',
          steps: const [
            _RoadStep('01', '5教科の基礎を穴なく', '英語・数学を軸にしつつ、国語の読解、理科の実験・計算、社会の資料読み取りを毎週回す。', '最優先'),
            _RoadStep('02', '理科・社会の得点を安定', '重要語句→一問一答→資料問題の順に進め、知識を使える形にする。', '毎日15分'),
            _RoadStep('03', '調査書・特色選抜の準備', '特色選抜を考える場合は、学科ごとの資格要件、自己表現シート、個人プレゼンテーションも確認。', '該当者'),
          ],
          source: '公式学校情報・入試情報： https://www.tochigi-edu.ed.jp/sanoshooh/nc3/学校紹介/学校情報・入試情報',
          footnote: '一般選抜と特色選抜で評価の構成が異なります。学科ごとの最新資料を確認してください。',
        ),
        const SizedBox(height: 18),
        const Text('今週の学習ルート', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        _weekTile('月・水・金', '数学＋英語', '計算・関数を10問、英単語と文法を10分'),
        _weekTile('火・木', '理科＋社会', '要点まとめを読んで、各教科10問'),
        _weekTile('土', '5教科ミックス', '時間を決めて演習。間違いを分野別に分類'),
        _weekTile('日', '弱点回収', '復習待ちを解き直し、翌週の重点を決める'),
        const SizedBox(height: 16),
        const Text('公式情報の確認先', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const SelectableText('青藍泰斗高校 https://www.seirantaito.ed.jp/entrance.html\n佐野松桜高校 https://www.tochigi-edu.ed.jp/sanoshooh/nc3/', style: TextStyle(color: Color(0xFFFFB15C), height: 1.7)),
        const SizedBox(height: 8),
        const Text('※頻出単元の優先順位は学習用の提案です。学校が公表した出題予告・配点ではありません。', style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
      ],
    ),
  );

  static Widget _schoolCard(BuildContext context, {
    required String title,
    required String label,
    required String summary,
    required List<_RoadStep> steps,
    required String source,
    required String footnote,
  }) => Card(
    color: _panel,
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _orange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(summary, style: const TextStyle(color: Colors.white70, height: 1.6)),
        const SizedBox(height: 14),
        ...steps.map((step) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 30, height: 30, alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFF3A281B), borderRadius: BorderRadius.circular(9)),
              child: Text(step.number, style: const TextStyle(color: _orange, fontWeight: FontWeight.w900))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w800))),
                Text(step.priority, style: const TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 3),
              Text(step.detail, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
            ])),
          ]),
        )),
        const Divider(color: Color(0xFF414149)),
        Text(footnote, style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.5)),
        const SizedBox(height: 7),
        SelectableText(source, style: const TextStyle(color: Color(0xFFFFB15C), fontSize: 11)),
      ]),
    ),
  );

  static Widget _weekTile(String day, String title, String detail) => Card(
    color: _panel,
    child: ListTile(
      leading: SizedBox(width: 76, child: Text(day, style: const TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 11))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(detail, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ),
  );
}

class _RoadStep {
  const _RoadStep(this.number, this.title, this.detail, this.priority);
  final String number;
  final String title;
  final String detail;
  final String priority;
}
