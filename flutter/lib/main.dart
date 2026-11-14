import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:manabixx_web/foundation_practice.dart';
import 'package:manabixx_web/kosen_practice.dart';
import 'package:manabixx_web/knowledge_library.dart';
import 'package:manabixx_web/foundation_roadmap.dart';
import 'package:manabixx_web/to_you.dart';
import 'package:manabixx_web/release_notes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

const _bg = Color(0xFF121214);
const _surface = Color(0xFF222226);
const _line = Color(0xFF333338);
const _orange = Color(0xFFFF7900);

void main() { usePathUrlStrategy(); runApp(const ManabiXXApp()); }

class ManabiXXApp extends StatelessWidget {
  const ManabiXXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MANABIXX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // Use the locally bundled Japanese typeface to keep glyph forms consistent.
        fontFamily: 'NotoSansJP',
        fontFamilyFallback: const ['sans-serif'],
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: _orange,
          secondary: Color(0xFFFF8A00),
          surface: _surface,
          error: Color(0xFFFF7777),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _line),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: _line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) => ColoredBox(
        color: _bg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      routes: {
        '/practice/foundation': (_) => const FoundationPracticePage(includeAllSubjects: true),
        '/practice/kosen': (_) => const _PasswordGatePage(password: 'kosen', title: '製作者専用モード', child: _ModeHomePage(mode: 'kosen')),
        '/practice/kosen/study': (_) => const _PasswordGatePage(password: 'kosen', title: '制作者専用モード', child: KosenPracticePage(title: '制作者専用モード', additionalDataPaths: ['/data/questions.json'])),
        '/practice/kosen/math-section-1': (_) => const _PasswordGatePage(password: 'kosen', title: '制作者専用モード', child: KosenPracticePage(dataPath: '/data/kosen-math-section-1.json', title: '数学・大問1集中演習', initialSubject: 'math')),
        '/practice/foundation-training': (_) => const _PasswordGatePage(password: 'haru', title: '下積みモード', child: _ModeHomePage(mode: 'foundation')),
        '/practice/foundation-training/study': (_) => const _PasswordGatePage(password: 'haru', title: '下積みモード', child: FoundationPracticePage(dataPath: '/data/foundation-training.json', title: '下積みモード', includeAllSubjects: true, additionalDataPaths: ['/data/questions.json', '/data/public-exam.json'])),
        '/records': (_) => const _ProgressPage(),
        '/to-you': (_) => const ToYouPage(),
        '/releases': (_) => const ReleaseNotesPage(),
        '/release-notes': (_) => const ReleaseNotesPage(),
        '/foundation': (_) => const FoundationPracticePage(includeAllSubjects: true),
        '/foundation/': (_) => const FoundationPracticePage(),
        '/exam': (_) => const FoundationPracticePage(
          dataPath: '/data/public-exam.json', title: '公立高校入試問題', includeAllSubjects: true),
        '/exam/': (_) => const FoundationPracticePage(
          dataPath: '/data/public-exam.json', title: '公立高校入試問題', includeAllSubjects: true),
        '/summary': (_) => const KnowledgeLibraryPage(title: '要点まとめ', initialSubject: 'science'),
        '/summary/': (_) => const KnowledgeLibraryPage(title: '要点まとめ', initialSubject: 'science'),
        '/summary/science': (_) => const KnowledgeLibraryPage(title: '理科の要点まとめ', initialSubject: 'science'),
        '/summary/science/': (_) => const KnowledgeLibraryPage(title: '理科の要点まとめ', initialSubject: 'science'),
        '/summary/social': (_) => const KnowledgeLibraryPage(title: '社会の要点まとめ', initialSubject: 'social'),
        '/summary/social/': (_) => const KnowledgeLibraryPage(title: '社会の要点まとめ', initialSubject: 'social'),
        '/mock-exam': (_) => const FoundationPracticePage(
          dataPath: '/data/mock-exams.json', title: '模試・予想問題', includeAllSubjects: true),
        '/mock-exam/': (_) => const FoundationPracticePage(
          dataPath: '/data/mock-exams.json', title: '模試・予想問題', includeAllSubjects: true),
        '/kosen': (_) => const _PasswordGatePage(password: 'kosen', title: '製作者専用モード', child: KosenPracticePage(title: '製作者専用モード')),
        '/kosen/': (_) => const _PasswordGatePage(password: 'kosen', title: '製作者専用モード', child: KosenPracticePage(title: '製作者専用モード')),
      },
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => const _AppHomePage(),
      ),
      home: const _AppHomePage(),
    );
  }
}

class _AppHomePage extends StatefulWidget {
  const _AppHomePage();
  @override
  State<_AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<_AppHomePage> {
  int _tab = 0;

  void _openStudy() => Navigator.of(context).pushNamed('/foundation');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _HomeDashboard(onStart: _openStudy),
            _StudyMenu(onSelect: (route) => Navigator.of(context).pushNamed(route)),
            const _ProgressPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF19191D),
          border: Border(top: BorderSide(color: _line)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 66,
            backgroundColor: const Color(0xFF19191D),
            indicatorColor: const Color(0xFF3A281B),
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_rounded), label: 'ホーム'),
              NavigationDestination(icon: Icon(Icons.bolt_rounded), label: '学習'),
              NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: '記録'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  const _HomeDashboard({required this.onStart});
  final VoidCallback onStart;
  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  int _todayAnswered = 0;
  bool _progressLoaded = false;
  static const _prefecture = 'https://www.pref.tochigi.lg.jp/m04/r09/r09kenritukoutougakkounyuugakushasennbatunikannsuruosirase.html';
  static const _schoolInfo = 'https://www.pref.tochigi.lg.jp/m04/r09/r09nyuugakushasennbatunikakarugakkoujouhouhounyuusijouhou.html';
  static const _privateInfo = 'https://www.pref.tochigi.lg.jp/b05/r9bosyuyoukou.html';

  @override
  void initState() { super.initState(); _loadTodayProgress(); }

  Future<void> _loadTodayProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      var total = 0;
      for (final key in prefs.getKeys().where((k) => k.startsWith('manabixx.learning.') && k.endsWith('.history'))) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        final rows = jsonDecode(raw) as List<dynamic>;
        total += rows.whereType<Map<String, dynamic>>().where((row) {
          final rawDate = row['completedAt'];
          final date = rawDate is String ? DateTime.tryParse(rawDate)?.toLocal() : null;
          return date != null && date.year == today.year && date.month == today.month && date.day == today.day;
        }).fold<int>(0, (sum, row) => sum + (row['total'] as int? ?? 0));
      }
      if (mounted) setState(() { _todayAnswered = total; _progressLoaded = true; });
    } catch (_) { if (mounted) setState(() => _progressLoaded = true); }
  }

  Future<void> _openExternal(String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('リンクを開けませんでした。')),
    );
  }

  Widget _heading(String title, String sub) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(sub, style: const TextStyle(color: Color(0xFF9999A1), fontSize: 11)),
    ]),
  );

  Widget _subject(String name, String detail, String key, IconData icon) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
        FoundationPracticePage(title: name + 'の基礎演習', includeAllSubjects: true, initialSubject: key))),
      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: const Color(0xFF382719), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _orange)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          Text(detail, style: const TextStyle(color: Color(0xFF9999A1), fontSize: 9)),
        ])),
        const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF77777F)),
      ])),
    ),
  );

  Widget _entry(IconData icon, String title, String sub, VoidCallback tap) => Card(
    child: ListTile(
      leading: Icon(icon, color: _orange),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      subtitle: Text(sub, style: const TextStyle(color: Color(0xFF9999A1), fontSize: 10)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: tap,
    ),
  );

  Widget _news(String title, String detail, String source, VoidCallback tap) => Card(
    child: ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      subtitle: Text(detail + '\n' + source,
        style: const TextStyle(color: Color(0xFF9999A1), fontSize: 10, height: 1.6)),
      isThreeLine: true,
      trailing: const Icon(Icons.open_in_new_rounded, color: _orange, size: 18),
      onTap: tap,
    ),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      const Row(children: [
        Text('MANABIXX', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        Spacer(), Icon(Icons.local_fire_department_rounded, color: _orange),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF24201D),
          borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF55402E))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('LEARN / PREPARE / GROW', style: TextStyle(color: _orange, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('今日の一歩を、\n得点につなげよう。', style: TextStyle(fontSize: 26, height: 1.35, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('基礎の確認から入試対策まで。今やることを、ここから。',
            style: TextStyle(color: Color(0xFFB6B6BE), fontSize: 12, height: 1.7)),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: widget.onStart, icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('基礎網羅問題を始める'))),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/exam'),
            icon: const Icon(Icons.assignment_outlined), label: const Text('公立高校入試問題へ'))),
        ]),
      ),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('今日の学習', style: TextStyle(fontWeight: FontWeight.w800))),
            const Text('目安 20問', style: TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_progressLoaded ? '$_todayAnswered' : '—', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
            const Padding(padding: EdgeInsets.only(bottom: 7, left: 6), child: Text('問回答', style: TextStyle(color: Color(0xFFB6B6BE), fontSize: 12))),
            const Spacer(),
            Text((_todayAnswered / 20 * 100).clamp(0, 100).round().toString() + '%', style: const TextStyle(color: _orange, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(
            value: (_todayAnswered / 20).clamp(0.0, 1.0).toDouble(), minHeight: 7,
            backgroundColor: const Color(0xFF3A3A40), color: _orange)),
        ],
      ))),
      const SizedBox(height: 21),
      _heading('教科から選ぶ', '教科をタップして、すぐに演習を始めよう。'),
      GridView.count(
        crossAxisCount: MediaQuery.sizeOf(context).width > 720 ? 3 : 2,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.35,
        children: [
          _subject('理科', '実験・現象・用語', 'science', Icons.science_outlined),
          _subject('社会', '地理・歴史・公民', 'social', Icons.public_outlined),
          _subject('数学', '計算・関数・図形', 'math', Icons.calculate_outlined),
          _subject('英語', '単語・文法・読解', 'english', Icons.translate_rounded),
          _subject('国語', '漢字・文法・読解', 'japanese', Icons.menu_book_outlined),
        ],
      ),
      const SizedBox(height: 21),
      _heading('学習メニュー', '目的に合わせて、次の一歩を選ぼう。'),
      _entry(Icons.menu_book_outlined, '要点まとめ', '理科・社会を参考書のように整理', () => Navigator.of(context).pushNamed('/summary')),
      _entry(Icons.assignment_outlined, '模試・予想問題', '5教科をまとめて実戦チェック', () => Navigator.of(context).pushNamed('/mock-exam')),
      _entry(Icons.mail_outline_rounded, '君へ', '勉強の途中で読みたいメッセージ', () => Navigator.of(context).pushNamed('/to-you')),
      const SizedBox(height: 20),
      _heading('2027年度・高校入試情報', '栃木県教育委員会などの公開資料。最新情報は必ず公式資料で確認してください。'),
      _news('県立高校入試の日程・要項', '学力検査は2027年2月24日。特色選抜の学校独自検査は2月25日・26日。', '県教育委員会・2026年10月16日更新', () => _openExternal(_prefecture)),
      _news('学校・学科別の入試情報', '学校ごとの検査内容や、学力検査と調査書の比重を確認。', '県教育委員会・2026年6月10日公表', () => _openExternal(_schoolInfo)),
      _news('私立高校の募集要項一覧', '2027年度の募集要項・募集人員などを確認。', '県・2026年9月1日公表', () => _openExternal(_privateInfo)),
      const SizedBox(height: 20),
      _heading('自分専用の学習スペース', '専用ホーム・学習記録・PWAを分けて使えるモード。'),
      _entry(Icons.repeat_rounded, '下積みモード', '5教科の基礎から、苦手を一つずつ克服', () => Navigator.of(context).pushNamed('/practice/foundation-training')),
      _entry(Icons.lock_outline_rounded, '制作者専用モード', '専用データ・演習履歴・教材の管理', () => Navigator.of(context).pushNamed('/practice/kosen')),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('最近のアップデート', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          SizedBox(height: 4),
          Text('新機能・問題追加・改善内容を公開しています。',
            style: TextStyle(color: Color(0xFF9999A1), fontSize: 10, height: 1.5)),
        ])),
        TextButton(onPressed: () => Navigator.of(context).pushNamed('/releases'), child: const Text('直近5件を見る')),
      ]))),
      const SizedBox(height: 12),
      const Center(child: Text('MANABIXX · LEARN AT YOUR OWN PACE',
        style: TextStyle(color: Color(0xFF68686F), fontSize: 9, letterSpacing: 1.2))),
    ],
  );
}

class _ModeHomePage extends StatefulWidget {
  const _ModeHomePage({required this.mode});
  final String mode;
  @override
  State<_ModeHomePage> createState() => _ModeHomePageState();
}

class _ModeHomePageState extends State<_ModeHomePage> {
  List<Map<String, dynamic>> _history = [];
  DateTime? _examDate;
  bool _loaded = false;

  bool get _kosen => widget.mode == 'kosen';
  String get _title => _kosen ? '制作者専用モード' : '下積みモード';
  String get _practiceRoute => _kosen ? '/practice/kosen/study' : '/practice/foundation-training/study';
  String get _historyKey => _kosen
      ? 'manabixx.mode.kosen.history'
      : 'manabixx.learning._data_foundation-training.json.history';
  String get _examDateKey => _kosen
      ? 'manabixx.mode.kosen.exam-date'
      : 'manabixx.mode.foundation.exam-date';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    final rows = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    final date = prefs.getString(_examDateKey);
    if (!mounted) return;
    setState(() {
      _history = rows.whereType<Map<String, dynamic>>().toList();
      _examDate = date == null ? null : DateTime.tryParse(date);
      _loaded = true;
    });
  }

  Set<String> get _activeDays => _history.map((item) {
    final raw = item['completedAt'];
    if (raw is! String) return '';
    final date = DateTime.tryParse(raw)?.toLocal();
    return date == null ? '' : '${date.year}-${date.month}-${date.day}';
  }).where((value) => value.isNotEmpty).toSet();

  int get _streak {
    final active = _activeDays;
    var day = DateTime.now();
    String key(DateTime d) => '${d.year}-${d.month}-${d.day}';
    if (!active.contains(key(day))) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (active.contains(key(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  Future<void> _setExamDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime(now.year, now.month, now.day + 60),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: '入試日を設定',
    );
    if (picked == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_examDateKey, picked.toIso8601String());
    if (mounted) setState(() => _examDate = picked);
  }


  void _openModeSubject(String subject, String label) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) {
      if (_kosen) return KosenPracticePage(title: '制作者専用モード',
        initialSubject: subject, additionalDataPaths: const ['/data/questions.json']);
      return FoundationPracticePage(dataPath: '/data/foundation-training.json',
        title: '下積みモード · ' + label, includeAllSubjects: true,
        additionalDataPaths: const ['/data/questions.json', '/data/public-exam.json'],
        initialSubject: subject);
    }));
  }

  Widget _modeSubject(String label, String subject, IconData icon) => Card(
    child: InkWell(borderRadius: BorderRadius.circular(15),
      onTap: () => _openModeSubject(subject, label),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        child: Row(children: [
          Icon(icon, color: _orange, size: 19), const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
          const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF77777F)),
        ]))),
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final examDays = _examDate?.difference(DateTime(now.year, now.month, now.day)).inDays;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
          tooltip: '通常ホームへ',
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
          icon: const Icon(Icons.home_outlined),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(_kosen ? 'FOCUS / KOSEN' : 'FOCUS / FOUNDATION',
            style: const TextStyle(color: _orange, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(_kosen ? '今日の一問が、合格に近づく。' : '基礎を積み重ねて、確かな得点力へ。',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Card(child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Icon(Icons.local_fire_department_rounded, color: _orange, size: 34.0 + (_streak.clamp(0, 7) * 2).toDouble()),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('連続学習日数', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(_loaded ? '$_streak 日' : '—', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              ])),
              Text('${_history.fold<int>(0, (sum, row) => sum + (row['total'] as int? ?? 0))}問',
                style: const TextStyle(color: Colors.white70)),
            ]),
          )),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('学習ヒートマップ', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(spacing: 5, runSpacing: 5, children: List.generate(28, (i) {
                final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 27 - i));
                final active = _activeDays.contains('${date.year}-${date.month}-${date.day}');
                return Tooltip(message: '${date.month}/${date.day}',
                  child: Container(width: 17, height: 17, decoration: BoxDecoration(
                    color: active ? const Color(0xFFFF7900) : const Color(0xFF38383E),
                    borderRadius: BorderRadius.circular(4))));
              })),
            ]),
          )),
          const SizedBox(height: 16),
          Card(child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: const Text('入試までのカウントダウン'),
            subtitle: Text(examDays == null ? '日程を設定すると残り日数を表示します。' : 'あと $examDays 日'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: _setExamDate,
          )),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('教科から選ぶ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('教科を選んで、すぐに問題演習へ。',
                style: TextStyle(color: Color(0xFF9999A1), fontSize: 11)),
              const SizedBox(height: 9),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width > 720 ? 3 : 2,
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 2.9,
                children: [
                  _modeSubject('数学', 'math', Icons.calculate_outlined),
                  _modeSubject('英語', 'english', Icons.translate_rounded),
                  _modeSubject('理科', 'science', Icons.science_outlined),
                  _modeSubject('社会', 'social', Icons.public_outlined),
                  _modeSubject('国語', 'japanese', Icons.menu_book_outlined),
                ],
              ),
            ],
          ))),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(_practiceRoute),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('学習を始める'),
          ),
          if (!_kosen) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FoundationRoadmapPage()),
              ),
              icon: const Icon(Icons.route_outlined),
              label: const Text('青藍泰斗・佐野松桜 合格マップ'),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/to-you'),
            icon: const Icon(Icons.mail_outline_rounded),
            label: const Text('君へ'),
          ),
          if (_kosen) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const KosenQuestionImportPage(storageKey: 'manabixx.mode.kosen.history.custom'),
                ),
              ),
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('過去問・オリジナル問題を取り込む'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/practice/kosen/math-section-1'),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('数学・大問1集中演習'),
            ),
          ],
          const SizedBox(height: 12),
          Text(_kosen
            ? 'このホームは制作者専用モード専用です。ブラウザーのメニューからホーム画面に追加すると、専用アプリとして起動できます。通知は画面左下から設定できます。'
            : 'このホームは下積みモード専用です。ブラウザーのメニューからホーム画面に追加すると、専用アプリとして起動できます。通知は画面左下から設定できます。',
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}

class _PasswordGatePage extends StatefulWidget {
  const _PasswordGatePage({required this.password, required this.title, required this.child});
  final String password;
  final String title;
  final Widget child;
  @override
  State<_PasswordGatePage> createState() => _PasswordGatePageState();
}

class _PasswordGatePageState extends State<_PasswordGatePage> {
  bool _authorized = false;
  bool _prompted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prompted) return;
    _prompted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPassword());
  }

  Future<void> _requestPassword() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final authKey = 'manabixx.mode.auth.${widget.password}';
    final lastAuth = prefs.getString(authKey);
    final authenticatedAt = lastAuth == null ? null : DateTime.tryParse(lastAuth);
    if (authenticatedAt != null && DateTime.now().difference(authenticatedAt) < const Duration(hours: 12)) {
      if (mounted) setState(() => _authorized = true);
      return;
    }
    final controller = TextEditingController();
    var error = '';
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(widget.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('このモードを開くにはパスワードが必要です。'),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                obscureText: true,
                onSubmitted: (value) {
                  if (value == widget.password) {
                    Navigator.of(dialogContext).pop(true);
                  } else {
                    setDialogState(() => error = 'パスワードが違います。もう一度入力してください。');
                    controller.clear();
                  }
                },
                decoration: const InputDecoration(labelText: 'パスワード'),
              ),
              if (error.isNotEmpty) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error, style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('戻る')),
            FilledButton(
              onPressed: () {
                if (controller.text == widget.password) {
                  Navigator.of(dialogContext).pop(true);
                } else {
                  setDialogState(() => error = 'パスワードが違います。もう一度入力してください。');
                  controller.clear();
                }
              },
              child: const Text('認証する'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted) return;
    if (accepted == true) {
      await prefs.setString(authKey, DateTime.now().toIso8601String());
      setState(() => _authorized = true);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) => _authorized
      ? widget.child
      : const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _StudyMenu extends StatelessWidget {
  const _StudyMenu({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
    children: [
      const Text('学習', style: TextStyle(
        color: _orange, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('学習メニュー', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 22),
      _MenuTile(icon: Icons.bolt_rounded, title: '基礎網羅問題',
        subtitle: '5教科の基礎をテンポよく', onTap: () => onSelect('/foundation')),
      _MenuTile(icon: Icons.school_outlined, title: '公立高校入試問題',
        subtitle: '入試形式で実戦演習', onTap: () => onSelect('/exam')),
      _MenuTile(icon: Icons.mail_outline_rounded, title: '君へ',
        subtitle: '受験の日々に寄り添うメッセージ', onTap: () => onSelect('/to-you')),
      _MenuTile(icon: Icons.menu_book_outlined, title: '要点まとめ',
        subtitle: '理科・社会を分野別に確認', onTap: () => onSelect('/summary')),
      _MenuTile(icon: Icons.assessment_outlined, title: '模試・予想問題',
        subtitle: '5教科の総合演習', onTap: () => onSelect('/mock-exam')),
      _MenuTile(icon: Icons.lock_outline_rounded, title: '製作者専用モード', subtitle: '認証制・5教科の実戦演習', onTap: () => onSelect('/practice/kosen')),
      _MenuTile(icon: Icons.calculate_outlined, title: '数学・大問1集中演習', subtitle: '計算・小問集合を重点反復', onTap: () => onSelect('/practice/kosen/math-section-1')),
      _MenuTile(icon: Icons.repeat_rounded, title: '下積みモード', subtitle: '5教科の基礎反復と苦手問題の復習', onTap: () => onSelect('/practice/foundation-training')),
    ],
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line)),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFF382719),
                borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: _orange)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF9999A1), fontSize: 12)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF77777F)),
          ]),
        ),
      ),
    ),
  );
}

class _ProgressPage extends StatelessWidget {
  const _ProgressPage();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.insights_rounded, size: 44, color: _orange),
        SizedBox(height: 14),
        Text('学習記録', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Text('演習履歴と復習待ちは、各教材の画面で確認できます。',
          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9999A1))),
      ]),
    ),
  );
}
