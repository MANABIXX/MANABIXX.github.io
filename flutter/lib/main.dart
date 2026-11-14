import 'package:material_ui/material_ui.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:manabixx_web/foundation_practice.dart';
import 'package:manabixx_web/kosen_practice.dart';
import 'package:manabixx_web/knowledge_library.dart';

void main() {
  useHashUrlStrategy();
  runApp(const ManabiXXApp());
}

class ManabiXXApp extends StatelessWidget {
  const ManabiXXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MANABIXX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B9CFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF111318),
        ),
        scaffoldBackgroundColor: const Color(0xFF08090C),
        useMaterial3: true,
      ),
      routes: {
        '/library': (_) => const KnowledgeLibraryPage(),
        '/library/': (_) => const KnowledgeLibraryPage(),
        '/foundation': (_) => const FoundationPracticePage(),
        '/foundation/': (_) => const FoundationPracticePage(),
        '/exam': (_) => const FoundationPracticePage(
              dataPath: 'data/public-exam.json',
              title: '公立高校入試問題',
            ),
        '/exam/': (_) => const FoundationPracticePage(
              dataPath: 'data/public-exam.json',
              title: '公立高校入試問題',
            ),
        '/summary': (_) => const FoundationPracticePage(
              dataPath: 'data/summary-foundation.json',
              title: '要点まとめ・基礎確認',
            ),
        '/summary/': (_) => const FoundationPracticePage(
              dataPath: 'data/summary-foundation.json',
              title: '要点まとめ・基礎確認',
            ),
        '/mock-exam': (_) => const FoundationPracticePage(
              dataPath: 'data/mock-exams.json',
              title: '模試・予想問題',
              includeAllSubjects: true,
            ),
        '/mock-exam/': (_) => const FoundationPracticePage(
              dataPath: 'data/mock-exams.json',
              title: '模試・予想問題',
              includeAllSubjects: true,
            ),
        '/kosen': (_) => const KosenPracticePage(),
        '/kosen/': (_) => const KosenPracticePage(),
      },
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('ページが見つかりません')),
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false),
              child: const Text('ホームへ戻る'),
            ),
          ),
        ),
      ),
      home: const MigrationHomePage(),
    );
  }
}

class MigrationHomePage extends StatelessWidget {
  const MigrationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANABIXX',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('Flutter Web preview')),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STUDY, STEP BY STEP',
                  style: TextStyle(
                    color: Color(0xFF9AA8FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '学びを、次の一歩へ。',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '基礎網羅問題をFlutter Webへ移植しました。既存の1,180問を読み込み、'
                  '教科・分野・問題数を選んで演習できます。公開サイトは維持したまま、'
                  'ほかの学習機能も順次移行します。',
                  style: TextStyle(height: 1.8, color: Color(0xFFB7BBC5)),
                ),
                const SizedBox(height: 24),
                const _MigrationStatusCard(),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/foundation'),
                      icon: const Icon(Icons.auto_stories_outlined),
                      label: const Text('基礎網羅問題を開く'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/library'),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('教材ライブラリ'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/exam'),
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('公立高校入試問題'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/summary'),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('要点まとめ'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/mock-exam'),
                      icon: const Icon(Icons.assessment_outlined),
                      label: const Text('模試・予想問題'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MigrationStatusCard extends StatelessWidget {
  const _MigrationStatusCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('移行ステータス', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            _StatusRow(label: 'Flutter Web基盤', value: '実装済み'),
            _StatusRow(label: '基礎網羅問題', value: '演習機能を実装'),
            _StatusRow(label: '教材・入試・進捗機能', value: '移行中'),
            _StatusRow(label: '公開サイトの切替', value: '未実施'),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(color: Color(0xFFB7BBC5))),
        ],
      ),
    );
  }
}
