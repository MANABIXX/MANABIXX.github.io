import 'package:flutter/material_ui.dart';

void main() {
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
                  'Flutter Webへの移行基盤です。現在の公開サイトはそのまま維持し、'
                  '画面・問題データ・学習履歴の互換性を確認しながら段階的に移植します。',
                  style: TextStyle(height: 1.8, color: Color(0xFFB7BBC5)),
                ),
                const SizedBox(height: 24),
                const _MigrationStatusCard(),
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
          children: const [
            Text('移行ステータス', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            _StatusRow(label: 'Flutter Web基盤', value: '準備中'),
            _StatusRow(label: '既存Study機能の移植', value: '未着手'),
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
