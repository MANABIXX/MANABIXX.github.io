import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoundationQuestion {
  const FoundationQuestion({
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

  factory FoundationQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>).cast<String>();
    final correct = json['correct'] as int;
    if (options.length != 4 || correct < 0 || correct > 3) {
      throw const FormatException('問題データの選択肢または正答番号が不正です。');
    }
    return FoundationQuestion(
      id: json['id'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String? ?? '',
      level: json['level'] as String? ?? '基礎',
      prompt: json['prompt'] as String,
      options: options,
      correct: correct,
      explanation: json['explanation'] as String? ?? '',
      sourceLabel: json['sourceLabel'] as String? ?? '',
      sourceNote: json['sourceNote'] as String? ?? '',
    );
  }
}

class FoundationPracticePage extends StatefulWidget {
  const FoundationPracticePage({
    super.key,
    this.loadQuestions,
    this.dataPath = '/data/questions.json',
    this.title = '基礎網羅問題',
    this.includeAllSubjects = false,
    this.additionalDataPaths = const [],
  });

  final Future<List<FoundationQuestion>> Function()? loadQuestions;
  final String dataPath;
  final String title;
  final bool includeAllSubjects;
  final List<String> additionalDataPaths;

  @override
  State<FoundationPracticePage> createState() => _FoundationPracticePageState();
}

class _FoundationPracticePageState extends State<FoundationPracticePage> {
  List<FoundationQuestion> _questions = [];
  List<FoundationQuestion> _session = [];
  String _subject = 'all';
  String _topic = 'all';
  String _amount = '10';
  String? _error;
  bool _loading = true;
  bool _started = false;
  bool _finished = false;
  int _index = 0;
  int _keyboardIndex = 0;
  int? _selected;
  int _score = 0;
  int _completedSessions = 0;
  int _totalAnswered = 0;
  int _totalCorrect = 0;
  List<String> _wrongQuestionIds = [];
  List<Map<String, dynamic>> _history = [];
  bool _progressStorageAvailable = true;

  String get _storageKey => 'manabixx.learning.${widget.dataPath.replaceAll('/', '_')}';

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_storageKey.history');
      final wrong = prefs.getStringList('$_storageKey.wrong') ?? [];
      final decoded = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
      final history = decoded.whereType<Map<String, dynamic>>().toList();
      if (!mounted) return;
      setState(() {
        _history = history;
        _wrongQuestionIds = wrong;
        _completedSessions = history.length;
        _totalAnswered = history.fold<int>(0, (sum, item) => sum + (item['total'] as int? ?? 0));
        _totalCorrect = history.fold<int>(0, (sum, item) => sum + (item['score'] as int? ?? 0));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _progressStorageAvailable = false);
    }
  }

  Future<void> _saveAnswer(FoundationQuestion question, int choice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (choice == question.correct) {
        _wrongQuestionIds.remove(question.id);
      } else if (!_wrongQuestionIds.contains(question.id)) {
        _wrongQuestionIds.add(question.id);
      }
      await prefs.setStringList('$_storageKey.wrong', _wrongQuestionIds);
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() => _progressStorageAvailable = false);
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _history.insert(0, {
        'completedAt': DateTime.now().toIso8601String(),
        'title': widget.title,
        'total': _session.length,
        'score': _score,
      });
      if (_history.length > 100) _history = _history.take(100).toList();
      await prefs.setString('$_storageKey.history', jsonEncode(_history));
      if (!mounted) return;
      setState(() {
        _completedSessions = _history.length;
        _totalAnswered += _session.length;
        _totalCorrect += _score;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _progressStorageAvailable = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadProgress();
  }

  Future<List<FoundationQuestion>> _fetchQuestions() async {
    final uri = Uri.base.resolve(widget.dataPath.startsWith('/') ? widget.dataPath : '/${widget.dataPath}');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('問題データを読み込めませんでした（HTTP ${response.statusCode}）。');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = <dynamic>[...(payload['questions'] as List<dynamic>)];
    for (final path in widget.additionalDataPaths) {
      final extraUri = Uri.base.resolve(path.startsWith('/') ? path : '/$path');
      final extraResponse = await http.get(extraUri);
      if (extraResponse.statusCode != 200) {
        throw Exception('追加問題データを読み込めませんでした（HTTP ${extraResponse.statusCode}）。');
      }
      final extraPayload = jsonDecode(extraResponse.body) as Map<String, dynamic>;
      raw.addAll(extraPayload['questions'] as List<dynamic>);
    }
    final byId = <String, FoundationQuestion>{};
    for (final item in raw) {
      final question = FoundationQuestion.fromJson(item as Map<String, dynamic>);
      byId.putIfAbsent(question.id, () => question);
    }
    return byId.values
        .where((item) => widget.includeAllSubjects ||
            item.subject == 'science' || item.subject == 'social')
        .toList(growable: false);
  }

  Future<void> _load() async {
    try {
      final loaded = await (widget.loadQuestions ?? _fetchQuestions)();
      if (!mounted) return;
      setState(() {
        _questions = loaded
            .where((item) => widget.includeAllSubjects ||
                item.subject == 'science' || item.subject == 'social')
            .toList(growable: false);
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<String> get _topics => _questions
      .where((item) => _subject == 'all' || item.subject == _subject)
      .map((item) => item.topic)
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<FoundationQuestion> get _available => _questions
      .where((item) =>
          (_subject == 'all' || item.subject == _subject) &&
          (_topic == 'all' || item.topic == _topic))
      .toList(growable: false);

  FoundationQuestion get _current => _session[_index];

  void _start() {
    final nextSession = [..._available]..shuffle(Random());
    final count = _amount == 'all' ? nextSession.length : int.parse(_amount);
    if (nextSession.isEmpty) return;
    setState(() {
      _session = nextSession.take(count).toList(growable: false);
      _index = 0;
      _keyboardIndex = 0;
      _selected = null;
      _score = 0;
      _started = true;
      _finished = false;
    });
  }

  void _startReview() {
    final reviewQuestions = _questions
        .where((question) => _wrongQuestionIds.contains(question.id))
        .toList()
      ..shuffle(Random());
    if (reviewQuestions.isEmpty) return;
    setState(() {
      _session = reviewQuestions;
      _index = 0;
      _selected = null;
      _score = 0;
      _started = true;
      _finished = false;
    });
  }



  Future<void> _answer(int choice) async {
    if (_selected != null) return;
    final question = _current;
    HapticFeedback.lightImpact();
    setState(() {
      _selected = choice;
      if (choice == question.correct) _score++;
    });
    _saveAnswer(question, choice);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted && _started && !_finished && _selected == choice) {
      _next();
    }
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

  void _back() {
    setState(() {
      _started = false;
      _finished = false;
      _selected = null;
    });
  }

  String _topicLabel(String value) => const {'civics':'公民','history':'歴史','geography':'地理','earth':'地学','physics':'物理','chemistry':'化学','biology':'生物'}[value.toLowerCase()] ?? value;

  String _subjectLabel(String value) => switch (value) {
        'science' => '理科',
        'social' => '社会',
        'math' => '数学',
        'english' => '英語',
        'japanese' => '国語',
        _ => '理科・社会',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _started && !_finished ? null : AppBar(
        title: Text(widget.title),
        leading: IconButton(
          tooltip: 'Studyホームへ戻る',
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
            constraints: const BoxConstraints(maxWidth: 1180),
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
            const Icon(Icons.cloud_off_outlined, size: 36),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('再読み込み')),
          ],
        ),
      );

  Widget _buildSelection() => ListView(
        children: [
          const SizedBox(height: 32),
          Text('基礎演習',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 2,
                  )),
          const SizedBox(height: 12),
          Text(widget.title == '基礎網羅問題' ? '基礎を、一問ずつ。' : '入試形式で、実力を試す。',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: 8),
          Text(widget.title == '基礎網羅問題'
              ? '5教科の基礎問題から、今取り組む範囲を選びます。'
              : widget.includeAllSubjects
                  ? '5教科の問題を組み合わせて、実戦形式で演習します。'
                  : '理科・社会の入試形式問題に挑戦します。出典情報も確認できます。'),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('収録問題', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text('${_questions.length}問',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text('学習記録：$_completedSessions回 · $_totalAnswered問回答 · 正解 $_totalCorrect問'),
                  Text('復習待ち：${_wrongQuestionIds.length}問',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (!_progressStorageAvailable)
                    Text(
                      'この端末では学習記録を保存できません。演習は続けられます。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _subject,
                    decoration: const InputDecoration(labelText: '教科'),
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(widget.includeAllSubjects ? '全教科' : '理科・社会'),
                      ),
                      const DropdownMenuItem(value: 'science', child: Text('理科')),
                      const DropdownMenuItem(value: 'social', child: Text('社会')),
                      if (widget.includeAllSubjects) ...[
                        const DropdownMenuItem(value: 'japanese', child: Text('国語')),
                        const DropdownMenuItem(value: 'math', child: Text('数学')),
                        const DropdownMenuItem(value: 'english', child: Text('英語')),
                      ],
                    ],
                    onChanged: (value) => setState(() {
                      _subject = value ?? 'all';
                      _topic = 'all';
                    }),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _topic,
                    decoration: const InputDecoration(labelText: '分野・単元'),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('すべて')),
                      ..._topics.map((topic) =>
                          DropdownMenuItem(value: topic, child: Text(_topicLabel(topic)))),
                    ],
                    onChanged: (value) =>
                        setState(() => _topic = value ?? 'all'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _amount,
                    decoration: const InputDecoration(labelText: '問題数'),
                    items: const [
                      DropdownMenuItem(value: '10', child: Text('10問')),
                      DropdownMenuItem(value: '20', child: Text('20問')),
                      DropdownMenuItem(value: '30', child: Text('30問')),
                      DropdownMenuItem(value: '50', child: Text('50問')),
                      DropdownMenuItem(value: 'all', child: Text('全問')),
                    ],
                    onChanged: (value) =>
                        setState(() => _amount = value ?? '10'),
                  ),
                  const SizedBox(height: 20),
                  Text('${_available.length}問から出題できます。',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _available.isEmpty ? null : _start,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('演習を始める'),
                    ),
                  ),
                  if (_wrongQuestionIds.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _startReview,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('間違えた問題を復習（${_wrongQuestionIds.length}問）'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildQuestion() {
    final question = _current;
    final answered = _selected != null;
    final correct = _selected == question.correct;

    final questionPanel = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
      decoration: BoxDecoration(
        color: const Color(0xFF222226),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF333338)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('問題', style: TextStyle(color: Color(0xFFFF8A00),
          letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        Text(question.prompt, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, height: 1.55,
            fontWeight: FontWeight.w800, color: Color(0xFFF5F5F6))),
        if (answered) ...[
          const SizedBox(height: 22),
          Text(correct ? '正解！' : '正解は ${String.fromCharCode(65 + question.correct)}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
              color: correct ? const Color(0xFF69D49A) : const Color(0xFFFF7777))),
        ],
        if (question.sourceLabel.isNotEmpty || question.sourceNote.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('${question.sourceLabel} ${question.sourceNote}'.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF85858D), height: 1.5)),
        ],
      ]),
    );

    final optionsPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(question.options.length, (i) {
          final isCorrect = i == question.correct;
          final isChosen = i == _selected;
          final bg = answered && isCorrect ? const Color(0xFF173B2B)
              : answered && isChosen ? const Color(0xFF422326) : const Color(0xFF222226);
          final border = answered && isCorrect ? const Color(0xFF3A9D6A)
              : answered && isChosen ? const Color(0xFFB94D55) : const Color(0xFF38383E);
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: SizedBox(
              height: 62,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: answered ? null : () => _answer(i),
                style: OutlinedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: const Color(0xFFF4F4F5),
                  disabledForegroundColor: const Color(0xFFF4F4F5),
                  side: BorderSide(color: !answered && i == _keyboardIndex
                    ? const Color(0xFFFF7900) : border,
                    width: !answered && i == _keyboardIndex ? 2 : 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(children: [
                  Container(width: 30, height: 30, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: answered && isCorrect ? const Color(0xFF28784D) : const Color(0xFF34343A),
                      borderRadius: BorderRadius.circular(9)),
                    child: Text(String.fromCharCode(65 + i),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                  const SizedBox(width: 13),
                  Expanded(child: Text(question.options[i],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  if (answered && isCorrect) const Icon(Icons.check_rounded, color: Color(0xFF69D49A)),
                  if (answered && isChosen && !isCorrect) const Icon(Icons.close_rounded, color: Color(0xFFFF7777)),
                ]),
              ),
            ),
          );
        }),
        if (answered && question.explanation.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF29292F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF414149))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('解説', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFFB15C))),
              const SizedBox(height: 7),
              Text(question.explanation, style: const TextStyle(height: 1.6)),
              const SizedBox(height: 8),
              const Text('Enterキーで次の問題へ', style: TextStyle(color: Color(0xFF99999A), fontSize: 11)),
            ]),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(minHeight: 4,
              value: (_index + 1) / _session.length,
              backgroundColor: const Color(0xFF333338), color: const Color(0xFFFF7900)))),
          const SizedBox(width: 14),
          Text('${_session.length - _index - 1}問',
            style: const TextStyle(color: Color(0xFFB8B8BE), fontSize: 12)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _PracticePill(text: _subjectLabel(question.subject)),
          if (question.topic.isNotEmpty) ...[
            const SizedBox(width: 8), _PracticePill(text: _topicLabel(question.topic)),
          ],
          const Spacer(),
          Text('${_index + 1}/${_session.length}',
            style: const TextStyle(color: Color(0xFF77777F), fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          return SingleChildScrollView(
            child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 6, child: questionPanel),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: optionsPanel),
                ])
              : Column(children: [questionPanel, const SizedBox(height: 18), optionsPanel]),
          );
        })),
      ],
    );
  }

  Widget _buildResult() => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 42),
                const SizedBox(height: 14),
                Text('演習完了',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text('$_score / ${_session.length}',
                    style: Theme.of(context).textTheme.displaySmall),
                Text('正答率 ${(_score / _session.length * 100).round()}%'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _start,
                    child: const Text('もう一度解く'),
                  ),
                ),
                TextButton(onPressed: _back, child: const Text('条件を変更する')),
              ],
            ),
          ),
        ),
      );
}


class _PracticePill extends StatelessWidget {
  const _PracticePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF29292E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF3A3A40)),
    ),
    child: Text(text, style: const TextStyle(
      fontSize: 11, color: Color(0xFFBDBDC4), fontWeight: FontWeight.w600)),
  );
}
