import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  });

  final String id;
  final String subject;
  final String topic;
  final String level;
  final String prompt;
  final List<String> options;
  final int correct;
  final String explanation;

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
    );
  }
}

class KosenPracticePage extends StatefulWidget {
  const KosenPracticePage({super.key, this.loadQuestions});

  final Future<List<KosenQuestion>> Function()? loadQuestions;

  @override
  State<KosenPracticePage> createState() => _KosenPracticePageState();
}

class _KosenPracticePageState extends State<KosenPracticePage> {
  static const _subjects = <String, String>{
    'all': '全教科',
    'math': '数学',
    'science': '理科',
    'english': '英語',
  };

  List<KosenQuestion> _questions = [];
  List<KosenQuestion> _session = [];
  String _subject = 'all';
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

  Future<List<KosenQuestion>> _fetchQuestions() async {
    final uri = Uri.base.resolve('data/kosen-questions.json');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('問題データを読み込めませんでした（HTTP ${response.statusCode}）。');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = payload['questions'] as List<dynamic>;
    return raw
        .map((item) => KosenQuestion.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> _load() async {
    try {
      final loaded = await (widget.loadQuestions ?? _fetchQuestions)();
      if (!mounted) return;
      setState(() {
        _questions = loaded;
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
      _session = nextSession;
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

  void _backToSelection() {
    setState(() {
      _started = false;
      _finished = false;
      _selected = null;
    });
  }

  String _subjectName(String value) => _subjects[value] ?? value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高専専用モード'),
        leading: IconButton(
          tooltip: 'MANABIXXホームへ戻る',
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
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _load, child: const Text('再読み込み')),
          ],
        ),
      );

  Widget _buildSelection() => ListView(
        children: [
          Text(
            'EXAM PRACTICE / INDEPENDENT MODE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '高専専用モード',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '数学・理科・英語のオリジナル問題を、教科ごとに演習できます。',
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
                    value: _subject,
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
            'このモードの問題は学習用のオリジナル問題です。公式過去問そのものではありません。',
          ),
        ],
      );

  Widget _buildQuestion() {
    final question = _current;
    final answered = _selected != null;
    return ListView(
      children: [
        Row(
          children: [
            Expanded(child: Text('${_subjectName(question.subject)} / ${question.topic}')),
            Text('${_index + 1} / ${_session.length}'),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: (_index + 1) / _session.length),
        const SizedBox(height: 28),
        Text(
          '${question.level} · QUESTION ${(_index + 1).toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          question.prompt,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: answered ? null : () => _answer(i),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                alignment: Alignment.centerLeft,
                side: BorderSide(
                  color: answered && i == question.correct
                      ? Colors.green
                      : answered && i == _selected
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    child: Text(String.fromCharCode(65 + i)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(question.options[i])),
                  if (answered && i == question.correct)
                    const Icon(Icons.check_circle, color: Colors.green),
                  if (answered && i == _selected && i != question.correct)
                    const Icon(Icons.cancel, color: Colors.redAccent),
                ],
              ),
            ),
          ),
        if (answered) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == question.correct ? '正解！' : '正解は ${String.fromCharCode(65 + question.correct)} です',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(question.explanation),
                ],
              ),
            ),
          ),
          FilledButton(
            onPressed: _next,
            child: Text(_index + 1 == _session.length ? '結果を見る' : '次の問題へ'),
          ),
        ],
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
              label: const Text('もう一度解く'),
            ),
            TextButton(onPressed: _backToSelection, child: const Text('教科選択へ戻る')),
          ],
        ),
      );
}
