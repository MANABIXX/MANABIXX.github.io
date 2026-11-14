import 'package:material_ui/material_ui.dart';

class ReleaseNotesPage extends StatelessWidget {
  const ReleaseNotesPage({super.key});

  static const _items = <_ReleaseEntry>[
    _ReleaseEntry(date: '2026-11-14', category: 'HOME / PORTAL', title: 'ホームを学習ポータルへ拡張',
      body: '教科別クイック演習、今日の学習量、学習メニュー、2027年度の高校入試情報、独立モードへの入口を整理。シンプルな黒基調を保ちながら、必要な情報へホームから移動できるようにしました。'),
    _ReleaseEntry(date: '2026-11-14', category: 'PRIVATE WORKSPACE', title: '専用モードの表示を整理',
      body: '専用モードの表示名を「制作者専用モード」に統一。専用ホーム、学習履歴、PWA設定、問題データの分離を維持し、ホームからの導線をわかりやすくしました。'),
    _ReleaseEntry(date: '2026-11-14', category: 'SUBJECT PRACTICE', title: '教科別のクイック演習を追加',
      body: '下積みモードと制作者専用モードに、数学・英語・理科・社会・国語の入口を追加。教科を選ぶだけで、そのモードに対応した問題データから演習を始められます。'),
    _ReleaseEntry(date: '2026-11-14', category: 'EXAM INFORMATION', title: '高校入試の公式情報をホームに掲載',
      body: '栃木県教育委員会が公開する県立高校の入試日程・学校別情報・私立高校募集要項へのリンクを追加。更新日と出典を併記し、必ず公式資料を確認できるようにしました。'),
    _ReleaseEntry(date: '2026-11-14', category: 'STUDY EXPERIENCE', title: 'オフライン・復習・合格マップを統合',
      body: '問題データの端末キャッシュ、苦手問題の蓄積と復習、解説を自分のペースで確認する操作、下積みモードの合格マップ、学習メッセージ「君へ」を利用できるようにしました。'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('更新履歴')),
    body: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), children: [
      const Text('RELEASE NOTES', style: TextStyle(color: Color(0xFFFF7900),
        fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('MANABIXXの更新記録', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('最近の変更を、新しい順に5件掲載しています。',
        style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6)),
      const SizedBox(height: 18),
      ..._items.map((item) => Card(margin: const EdgeInsets.only(bottom: 11),
        child: Padding(padding: const EdgeInsets.all(17), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(item.date, style: const TextStyle(color: Color(0xFFB7B7BE), fontSize: 10)),
              const Spacer(),
              Text(item.category, style: const TextStyle(color: Color(0xFFFF7900),
                fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
            const SizedBox(height: 9),
            Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, height: 1.4)),
            const SizedBox(height: 8),
            Text(item.body, style: const TextStyle(color: Color(0xFFB7B7BE), fontSize: 12, height: 1.8)),
          ],
        )),
      )),
      const SizedBox(height: 8),
      const Center(child: Text('MANABIXX · CHANGELOG',
        style: TextStyle(color: Color(0xFF77777F), fontSize: 9, letterSpacing: 1.2))),
    ]),
  );
}

class _ReleaseEntry {
  const _ReleaseEntry({required this.date, required this.category, required this.title, required this.body});
  final String date, category, title, body;
}
