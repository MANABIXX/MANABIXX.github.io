import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KosenQuestion {
  const KosenQuestion({
    required this.id,
    required this.subject,
    required this.topic,
    required this.level,
    required this.prompt,
    required this.options,
    required this.correct,
    required this.explanation,
    this.sourceLabel = '',
    this.sourceNote = '',
  });

  final String id;
  final String subject;
  final String topic;
  final String level;
  final String prompt;
  final List<String> options;
  final int correct;
  final String explanation;
  final String sourceLabel;
  final String sourceNote;

  factory KosenQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>).cast<String>();
    final correct = json['correct'] as int;
    if (options.length != 4 || correct < 0 || correct > 3) {
      throw const FormatException('問題データの選択肢または正答番号が不正です。');
    }
    return KosenQuestion(
      id: json['id'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      level: json['level'] as String,
      prompt: json['prompt'] as String,
      options: options,
      correct: correct,
      explanation: json['explanation'] as String,
      sourceLabel: json['sourceLabel'] as String? ?? '',
      sourceNote: json['sourceNote'] as String? ?? '',
    );
  }
}

class KosenPracticePage extends StatefulWidget {
  const KosenPracticePage({super.key, this.loadQuestions, this.dataPath = '/data/kosen-questions.json', this.title = '製作者専用モード', this.initialSubject = 'all', this.additionalDataPaths = const []});

  final Future<List<KosenQuestion>> Function()? loadQuestions;
  final String dataPath;
  final String title;
  final String initialSubject;
  final List<String> additionalDataPaths;

  @override
  State<KosenPracticePage> createState() => _KosenPracticePageState();
}

class _KosenPracticePageState extends State<KosenPracticePage> {
  static const _subjects = <String, String>{
    'all': '全教科',
    'math': '数学',
    'science': '理科',
    'english': '英語',
    'social': '社会',
    'japanese': '国語',
  };

  List<KosenQuestion> _questions = [];
  List<KosenQuestion> _session = [];
  late String _subject = widget.initialSubject;
  String? _error;
  bool _loading = true;
  bool _started = false;
  bool _finished = false;
  int _index = 0;
  int _keyboardIndex = 0;
  int? _selected;
  int _score = 0;
  List<String> _wrongQuestionIds = [];
  String get _historyKey => widget.dataPath == '/data/kosen-questions.json' ? 'manabixx.mode.kosen.history' : 'manabixx.mode.kosen.history.${widget.dataPath.hashCode}';
  String get _wrongKey => '$_historyKey.wrong';

  @override
  void initState() {
    super.initState();
    _load();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() => _wrongQuestionIds = prefs.getStringList(_wrongKey) ?? []);
    } catch (_) {}
  }

  Future<void> _saveAnswer(KosenQuestion question, int choice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (choice == question.correct) {
        _wrongQuestionIds.remove(question.id);
      } else if (!_wrongQuestionIds.contains(question.id)) {
        _wrongQuestionIds.add(question.id);
      }
      await prefs.setStringList(_wrongKey, _wrongQuestionIds);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _startReview() {
    final review = _questions.where((question) => _wrongQuestionIds.contains(question.id)).toList()
      ..shuffle(Random());
    if (review.isEmpty) return;
    setState(() {
      _session = review;
      _index = 0;
      _keyboardIndex = 0;
      _selected = null;
      _score = 0;
      _started = true;
      _finished = false;
    });
  }

  Future<List<KosenQuestion>> _fetchQuestions() async {
    final paths = [widget.dataPath, ...widget.additionalDataPaths];
    final combined = <KosenQuestion>[];
    final ids = <String>{};
    for (final path in paths) {
      final uri = Uri.base.resolve(path);
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('問題データを読み込めませんでした（HTTP ${response.statusCode}）。');
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = payload['questions'] as List<dynamic>;
      for (final item in raw) {
        final question = KosenQuestion.fromJson(item as Map<String, dynamic>);
        if (ids.add(question.id)) combined.add(question);
      }
    }
    return combined;
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await (widget.loadQuestions ?? _fetchQuestions)();
      if (!mounted) return;
      setState(() {
        _questions = loaded;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<KosenQuestion> get _available => _questions
      .where((question) => _subject == 'all' || question.subject == _subject)
      .toList(growable: false);

  KosenQuestion get _current => _session[_index];

  void _start() {
    final nextSession = [..._available]..shuffle(Random());
    if (nextSession.isEmpty) return;
    setState(() {
      _session = nextSession.take(10).toList(growable: false);
      _index = 0;
      _keyboardIndex = 0;
      _selected = null;
      _score = 0;
      _started = true;
      _finished = false;
    });
  }

  void _answer(int choice) {
    if (_selected != null) return;
    final correct = choice == _current.correct;
    setState(() {
      _selected = choice;
      if (correct) _score++;
    });
    if (correct) unawaited(HapticFeedback.mediumImpact());
    unawaited(_saveAnswer(_current, choice));
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _historyKey;
      final rows = (jsonDecode(prefs.getString(key) ?? '[]') as List<dynamic>)
          .whereType<Map<String, dynamic>>().toList();
      rows.insert(0, {'completedAt': DateTime.now().toIso8601String(), 'title': widget.title, 'total': _session.length, 'score': _score});
      await prefs.setString(key, jsonEncode(rows.take(120).toList()));
    } catch (_) {}
  }

  void _next() {
    final completes = _index + 1 == _session.length;
    setState(() {
      if (completes) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
      }
    });
    if (completes) _saveSession();
  }

  void _backToSelection() {
    setState(() {
      _started = false;
      _finished = false;
      _selected = null;
    });
  }

  String _subjectName(String value) => _subjects[value] ?? value;
  String _topicName(String value) => const {'civics':'公民','history':'歴史','geography':'地理','earth':'地学','physics':'物理','chemistry':'化学','biology':'生物'}[value.toLowerCase()] ?? value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _started && !_finished && _selected != null
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(_index + 1 == _session.length ? '結果を見る' : '次の問題へ'),
                  ),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          tooltip: 'MANABIXXホームへ戻る',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent || !_started || _finished) return KeyEventResult.ignored;
          final key = event.logicalKey;
          if (_selected != null) { if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) { _next(); return KeyEventResult.handled; } return KeyEventResult.ignored; }
          if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowUp) { setState(() => _keyboardIndex = (_keyboardIndex + 3) % 4); return KeyEventResult.handled; }
          if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowDown) { setState(() => _keyboardIndex = (_keyboardIndex + 1) % 4); return KeyEventResult.handled; }
          if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1 || key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2 || key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3 || key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
            final digit = key.keyId >= LogicalKeyboardKey.numpad1.keyId ? key.keyId - LogicalKeyboardKey.numpad1.keyId + 1 : key.keyId - LogicalKeyboardKey.digit1.keyId + 1;
            setState(() => _keyboardIndex = digit - 1); return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) { _answer(_keyboardIndex); return KeyEventResult.handled; }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : !_started
                          ? _buildSelection()
                          : _finished
                              ? _buildResult()
                              : _buildQuestion(),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _retry, child: const Text('再読み込み')),
          ],
        ),
      );

  Widget _buildSelection() => ListView(
        children: [
          Text(
            '入試対策 / 集中演習',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '偏差値65を目標に、5教科の基礎から応用まで段階的に取り組む4択演習です。',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('教科を選ぶ', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _subject,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '出題範囲',
                    ),
                    items: _subjects.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _subject = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('対象問題：${_available.length}問'),
                  const SizedBox(height: 8),
                  Text('復習待ち：${_wrongQuestionIds.length}問'),
                  if (_wrongQuestionIds.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _startReview,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('苦手問題を復習（${_wrongQuestionIds.length}問）'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _available.isEmpty ? null : _start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('演習を始める'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('収録問題：${_questions.length}問'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _subjects.entries
                .where((entry) => entry.key != 'all')
                .map((entry) => Chip(
                      label: Text(
                        '${entry.value} ${_questions.where((q) => q.subject == entry.key).length}問',
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '収録問題は過去問の設問を転載せず、出題形式を参考に新規作成したオリジナル問題です。',
          ),
        ],
      );

  Widget _buildQuestion() {
    final question = _current;
    final answered = _selected != null;
    final twoColumns = MediaQuery.sizeOf(context).width >= 900;

    final questionPanel = Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${question.level} · 問題 ${(_index + 1).toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Text(question.prompt,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.55, fontWeight: FontWeight.w800)),
            if (question.sourceLabel.isNotEmpty || question.sourceNote.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('${question.sourceLabel} ${question.sourceNote}'.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFB6B6BE), height: 1.5)),
            ],
          ],
        ),
      ),
    );

    final choicesPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: answered ? null : () => _answer(i),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                alignment: Alignment.centerLeft,
                side: BorderSide(
                  color: !answered && i == _keyboardIndex
                      ? Theme.of(context).colorScheme.primary
                      : answered && i == question.correct
                          ? Colors.green
                          : answered && i == _selected
                              ? Colors.redAccent
                              : Theme.of(context).colorScheme.outline,
                  width: !answered && i == _keyboardIndex ? 2 : 1),
              ),
              child: Row(children: [
                CircleAvatar(radius: 14, child: Text(String.fromCharCode(65 + i))),
                const SizedBox(width: 12),
                Expanded(child: Text(question.options[i])),
                if (answered && i == question.correct) const Icon(Icons.check_circle, color: Colors.green),
                if (answered && i == _selected && i != question.correct) const Icon(Icons.cancel, color: Colors.redAccent),
              ]),
            ),
          ),
        if (answered) Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_selected == question.correct ? '正解！' : '正解は ${String.fromCharCode(65 + question.correct)} です',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(question.explanation),
              const SizedBox(height: 8),
              const Text('解説を確認したら、画面下の「次の問題へ」を押してください。', style: TextStyle(color: Color(0xFF99999A), fontSize: 12)),
            ]),
          ),
        ),
      ],
    );

    return ListView(
      children: [
        Row(children: [
          Expanded(child: Text('${_subjectName(question.subject)} / ${_topicName(question.topic)}')),
          Text('${_index + 1} / ${_session.length}'),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: (_index + 1) / _session.length),
        const SizedBox(height: 24),
        if (twoColumns)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 6, child: questionPanel),
            const SizedBox(width: 20),
            Expanded(flex: 5, child: choicesPanel),
          ])
        else
          Column(children: [questionPanel, const SizedBox(height: 18), choicesPanel]),
      ],
    );
  }

  Widget _buildResult() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 48),
            const SizedBox(height: 16),
            Text('演習完了', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '$_score / ${_session.length}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text('正答率 ${(_score / _session.length * 100).round()}%'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.refresh),
              label: const Text('次の10問へ（目安3分）'),
            ),
            TextButton(onPressed: _backToSelection, child: const Text('教科選択へ戻る')),
          ],
        ),
      );
}
