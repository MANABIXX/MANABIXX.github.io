import 'package:material_ui/material_ui.dart';

const _orange = Color(0xFFFF7900);
const _panel = Color(0xFF222226);

class FoundationRoadmapPage extends StatelessWidget {
  const FoundationRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('入試情報マップ'),
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
        const Text('入試の条件を確認し、\n今日やることに落とし込む。', style: TextStyle(fontSize: 26, height: 1.35, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        const Text('学校名を表示せず、どの入試にも共通する確認ポイントをまとめています。最新の募集要項は、受験する学校の公式案内で確認してください。', style: TextStyle(color: Colors.white70, height: 1.6)),
        const SizedBox(height: 22),
        _infoCard('試験方式・科目を確認', '単願・併願、一般選抜・特色選抜などの区分を先に確認し、自分が受ける方式の試験科目を整理します。', const [
          _RoadStep('01', '受験区分', '出願できる方式と条件を募集要項で照合する。', '最初に確認'),
          _RoadStep('02', '試験科目', '3教科・5教科など、実際の科目と範囲を確認する。', '必須'),
          _RoadStep('03', '出題形式', '記述・選択・面接など、準備が必要な形式を整理する。', '必要に応じて'),
        ]),
        const SizedBox(height: 14),
        _infoCard('日程・配点・評価方法', '試験日だけでなく、調査書や独自検査の扱い、合格発表日も一緒に確認します。', const [
          _RoadStep('01', '試験日と出願期間', '学校と中学校からの最新案内を照合する。', '必須'),
          _RoadStep('02', '配点と調査書', '学力検査以外の評価項目と比重を確認する。', '必須'),
          _RoadStep('03', '手続き期限', '合格発表後の書類・納入期限をカレンダーへ記録する。', '忘れずに'),
        ]),
        const SizedBox(height: 14),
        _infoCard('確認した条件を学習計画へ', '入試情報を確認したら、配点や苦手分野に合わせて、毎日の演習へ落とし込みます。', const [
          _RoadStep('01', '基礎の穴を探す', '教科ごとに、正答できない単元を一つずつ特定する。', '毎日'),
          _RoadStep('02', '時間を測って演習', '本番の形式に合わせて、時間配分も練習する。', '週1回'),
          _RoadStep('03', '間違いを解き直す', '翌日と週末にもう一度解き、できる状態まで戻す。', '継続'),
        ]),
        const SizedBox(height: 18),
        const Text('今週の学習ルート', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        _weekTile('月・水・金', '数学＋英語', '計算・関数を10問、英単語と文法を10分'),
        _weekTile('火・木', '理科＋社会', '要点を確認して、各教科10問'),
        _weekTile('土', '5教科ミックス', '時間を決めて演習。間違いを分野別に分類'),
        _weekTile('日', '弱点回収', '復習待ちを解き直し、翌週の重点を決める'),
        const SizedBox(height: 16),
        const Text('大切な確認', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('入試日程・科目・配点・出願条件は年度によって変わることがあります。過去の情報だけで判断せず、出願前に必ず最新の公式募集要項を確認してください。', style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6)),
      ],
    ),
  );

  static Widget _infoCard(String title, String summary, List<_RoadStep> steps) => Card(
    color: _panel,
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _orange, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        Text(summary, style: const TextStyle(color: Colors.white70, height: 1.6)),
        const SizedBox(height: 14),
        ...steps.map((step) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
