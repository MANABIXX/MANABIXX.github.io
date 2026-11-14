import 'dart:convert';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

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
  });

  final String id;
  final String subject;
  final String topic;
  final String level;
  final String prompt;
  final List<String> options;
  final int correct;
  final String explanation;

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
    );
  }
}

class FoundationPracticePage extends StatefulWidget {
  const FoundationPracticePage({super.key, this.loadQuestions});

  final Future<List<FoundationQuestion>> Function()? loadQuestions;

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
  int? _selected;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<List<FoundationQuestion>> _fetchQuestions() async {
    final uri = Uri.base.resolve('data/questions.json');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('問題データを読み込めませんでした（HTTP ${response.statusCode}）。');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = payload['questions'] as List<dynamic>;
    return raw
        .map((item) => FoundationQuestion.fromJson(item as Map<String, dynamic>))
        .where((item) => item.subject == 'science' || item.subject == 'social')
        .toList(growable: false);
  }

  Future<void> _load() async {
    try {
      final loaded = await (widget.loadQuestions ?? _fetchQuestions)();
      if (!mounted) return;
      setState(() {
        _questions = loaded
            .where((item) => item.subject == 'science' || item.subject == 'social')
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
      _selected = null;
      _score = 0;
      _started = true;
      _finished = false;
    });
  }

  void _answer(int choice) {
    if (_selected != null) return;
    setState(() {
      _selected = choice;
      if (choice == _current.correct) _score++;
    });
  }

  void _next() {
    setState(() {
      if (_index + 1 == _session.length) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
      }
    });
  }

  void _back() {
    setState(() {
      _started = false;
      _finished = false;
      _selected = null;
    });
  }

  String _subjectLabel(String value) => switch (value) {
        'science' => '理科',
        'social' => '社会',
        _ => '理科・社会',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基礎網羅問題'),
        leading: IconButton(
          tooltip: 'Studyホームへ戻る',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
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
          Text('FOUNDATION / PRACTICE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 2,
                  )),
          const SizedBox(height: 12),
          Text('基礎を、一問ずつ。',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: 8),
          const Text('理科・社会の基礎問題から、今取り組む範囲を選びます。'),
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
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _subject,
                    decoration: const InputDecoration(labelText: '教科'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('理科・社会')),
                      DropdownMenuItem(value: 'science', child: Text('理科')),
                      DropdownMenuItem(value: 'social', child: Text('社会')),
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
                          DropdownMenuItem(value: topic, child: Text(topic))),
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
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildQuestion() {
    final question = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
              label: const Text('一覧へ戻る'),
            ),
            const Spacer(),
            Text('${_index + 1} / ${_session.length}',
                style: const TextStyle(fontFeatures: [])),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (_index + 1) / _session.length),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(_subjectLabel(question.subject))),
            Chip(label: Text(question.topic)),
            Chip(label: Text(question.level)),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              question.prompt,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        ...List.generate(question.options.length, (i) {
          final answered = _selected != null;
          final correct = i == question.correct;
          final chosen = _selected == i;
          final background = answered && correct
              ? Theme.of(context).colorScheme.primaryContainer
              : answered && chosen
                  ? Theme.of(context).colorScheme.errorContainer
                  : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                  backgroundColor: background,
                ),
                onPressed: answered ? null : () => _answer(i),
                child: Text('${String.fromCharCode(65 + i)}. ${question.options[i]}'),
              ),
            ),
          );
        }),
        if (_selected != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == question.correct ? '正解！' : '不正解',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _selected == question.correct
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(question.explanation),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _next,
            child: Text(_index + 1 == _session.length ? '結果を見る' : '次の問題へ'),
          ),
        ],
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
