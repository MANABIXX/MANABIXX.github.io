import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:manabixx_web/foundation_practice.dart';
import 'package:manabixx_web/kosen_practice.dart';
import 'package:manabixx_web/knowledge_library.dart';
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
        '/practice/kosen/study': (_) => const _PasswordGatePage(password: 'kosen', title: '高専モード', child: KosenPracticePage(title: '高専モード', additionalDataPaths: ['/data/questions.json'])),
        '/practice/kosen/math-section-1': (_) => const _PasswordGatePage(password: 'kosen', title: '高専モード', child: KosenPracticePage(dataPath: '/data/kosen-math-section-1.json', title: '数学・大問1集中演習', initialSubject: 'math')),
        '/practice/foundation-training': (_) => const _PasswordGatePage(password: 'haru', title: '下積みモード', child: _ModeHomePage(mode: 'foundation')),
        '/practice/foundation-training/study': (_) => const _PasswordGatePage(password: 'haru', title: '下積みモード', child: FoundationPracticePage(dataPath: '/data/foundation-training.json', title: '下積みモード', includeAllSubjects: true, additionalDataPaths: ['/data/public-exam.json'])),
        '/records': (_) => const _ProgressPage(),
        '/foundation': (_) => const FoundationPracticePage(includeAllSubjects: true),
        '/foundation/': (_) => const FoundationPracticePage(),
        '/exam': (_) => const FoundationPracticePage(
          dataPath: '/data/public-exam.json', title: '公立高校入試問題'),
        '/exam/': (_) => const FoundationPracticePage(
          dataPath: '/data/public-exam.json', title: '公立高校入試問題'),
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

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
  }

  Future<void> _loadTodayProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      var answered = 0;
      final historyKeys = prefs.getKeys().where((key) =>
          key.startsWith('manabixx.learning.') && key.endsWith('.history'));
      for (final key in historyKeys) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        final history = jsonDecode(raw) as List<dynamic>;
        answered += history.whereType<Map<String, dynamic>>().where((item) {
          final value = item['completedAt'];
          if (value is! String) return false;
          final date = DateTime.tryParse(value)?.toLocal();
          return date != null && date.year == today.year &&
              date.month == today.month && date.day == today.day;
        }).fold<int>(0, (sum, item) => sum + (item['total'] as int? ?? 0));
      }
      if (!mounted) return;
      setState(() {
        _todayAnswered = answered;
        _progressLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _progressLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('MANABIXX', style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Spacer(),
            Icon(Icons.local_fire_department_rounded, color: _orange),
          ],
        ),
        const SizedBox(height: 44),
        const Text('TODAY', style: TextStyle(
          color: _orange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 10),
        const Text('今日も、一歩ずつ。', style: TextStyle(
          fontSize: 27, height: 1.35, fontWeight: FontWeight.w900)),
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface, borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('今日の学習', style: TextStyle(color: Color(0xFFB6B6BE), fontSize: 13)),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_progressLoaded ? '$_todayAnswered' : '—',
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                const Padding(padding: EdgeInsets.only(bottom: 8, left: 6),
                  child: Text('問回答', style: TextStyle(color: Color(0xFFB6B6BE)))),
                const Spacer(),
                const Text('TODAY', style: TextStyle(color: _orange, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: LinearProgressIndicator(
                  value: (_todayAnswered / 20).clamp(0.0, 1.0).toDouble(),
                  minHeight: 6,
                  backgroundColor: const Color(0xFF3A3A40), color: _orange)),
              const SizedBox(height: 8),
              const Text('今日の回答数 · 目安 20問',
                style: TextStyle(color: Color(0xFF77777F), fontSize: 11)),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 68,
          child: FilledButton.icon(
            onPressed: widget.onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 27),
            label: const Text('学習スタート', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    ),
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
  bool _remindersEnabled = false;

  bool get _kosen => widget.mode == 'kosen';
  String get _title => _kosen ? '高専モード' : '下積みモード';
  String get _practiceRoute => _kosen ? '/practice/kosen/study' : '/practice/foundation-training/study';
  String get _historyKey => _kosen
      ? 'manabixx.mode.kosen.history'
      : 'manabixx.learning._data_foundation-training.json.history';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    final rows = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    final date = prefs.getString('manabixx.exam-date');
    if (!mounted) return;
    setState(() {
      _history = rows.whereType<Map<String, dynamic>>().toList();
      _examDate = date == null ? null : DateTime.tryParse(date);
      _remindersEnabled = prefs.getBool('manabixx.reminders.enabled') ?? false;
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
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: '入試日を設定',
    );
    if (picked == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manabixx.exam-date', picked.toIso8601String());
    if (mounted) setState(() => _examDate = picked);
  }

  Future<void> _toggleReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !_remindersEnabled;
    await prefs.setBool('manabixx.reminders.enabled', next);
    if (!mounted) return;
    setState(() => _remindersEnabled = next);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(next
        ? '通知設定を有効にしました。ブラウザーの通知許可と、アプリを開いている状態が必要です。'
        : '通知設定をオフにしました。',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final examDays = _examDate == null ? null : _examDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
          tooltip: '通常ホームへ',
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
          icon: const Icon(Icons.home_outlined),
        ),
        actions: [
          IconButton(
            tooltip: '学習リマインダー',
            onPressed: _toggleReminder,
            icon: Icon(_remindersEnabled ? Icons.notifications_active : Icons.notifications_none),
          ),
        ],
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
              Icon(Icons.local_fire_department_rounded, color: _orange, size: 34 + (_streak.clamp(0, 7) * 2).toDouble()),
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
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(_practiceRoute),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('学習を始める'),
          ),
          if (_kosen) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/practice/kosen/math-section-1'),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('数学・大問1集中演習'),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _toggleReminder,
            icon: Icon(_remindersEnabled ? Icons.notifications_off_outlined : Icons.notifications_active_outlined),
            label: Text(_remindersEnabled ? '学習通知をオフ' : '学習リマインダーを設定'),
          ),
          const SizedBox(height: 8),
          Text(_kosen
            ? 'このホームは高専モード専用です。ブラウザーのメニューからホーム画面に追加すると、専用アプリとして起動できます。'
            : 'このホームは下積みモード専用です。ブラウザーのメニューからホーム画面に追加すると、専用アプリとして起動できます。',
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
