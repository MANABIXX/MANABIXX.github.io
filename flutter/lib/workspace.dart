import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key, this.loadQuestions});
  final Future<List<Map<String, dynamic>>> Function()? loadQuestions;

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  static const _tasksKey = 'manabixx-planner-tasks-v1';
  final _taskController = TextEditingController();
  final _noteController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _questions = [];
  String _subject = '理科';
  int _minutes = 25;
  int _remaining = 1500;
  int _focusCount = 0;
  int _cardIndex = 0;
  bool _flipped = false;
  bool _noteSaved = true;
  bool _ready = false;
  bool _loadingQuestions = true;
  String? _questionError;
  Timer? _timer;

  String get _today {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get _todayTasks =>
      _tasks.where((task) => task['date'] == _today).toList();
  int get _done => _todayTasks.where((task) => task['done'] == true).length;
  String get _clock =>
      '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _loadLocal();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tasksKey);
      final rows = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
      final note = prefs.getString('manabixx-planner-note-${_today}') ?? '';
      final count = int.tryParse(
            prefs.getString('manabixx-focus-count-${_today}') ?? '',
          ) ??
          0;
      if (!mounted) return;
      setState(() {
        _tasks = rows
            .whereType<Map<String, dynamic>>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
        _noteController.text = note;
        _focusCount = count;
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _ready = true);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchQuestions() async {
    if (widget.loadQuestions != null) return widget.loadQuestions!();
    final response = await http.get(Uri.base.resolve('/data/questions.json'));
    if (response.statusCode != 200) {
      throw Exception('問題データを読み込めませんでした（HTTP ${response.statusCode}）。');
    }
    final decoded = jsonDecode(response.body);
    final rows = decoded is Map<String, dynamic> ? decoded['questions'] : decoded;
    if (rows is! List) throw const FormatException('問題データの形式が正しくありません。');
    return rows
        .whereType<Map<String, dynamic>>()
        .where((row) =>
            row['prompt'] is String &&
            row['options'] is List &&
            (row['options'] as List).length == 4 &&
            row['correct'] is int &&
            (row['correct'] as int) >= 0 &&
            (row['correct'] as int) < 4)
        .take(100)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<void> _loadQuestions() async {
    try {
      final rows = await _fetchQuestions();
      if (!mounted) return;
      setState(() {
        _questions = rows;
        _loadingQuestions = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _questionError = error.toString();
        _loadingQuestions = false;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, jsonEncode(_tasks));
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _tasks.insert(0, {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'title': title,
        'subject': _subject,
        'minutes': _minutes,
        'date': _today,
        'done': false,
      });
      _taskController.clear();
    });
    await _saveTasks();
  }

  Future<void> _toggleTask(String id) async {
    setState(() {
      _tasks = _tasks.map((task) => task['id'] == id
          ? {...task, 'done': task['done'] != true}
          : task).toList();
    });
    await _saveTasks();
  }

  Future<void> _deleteTask(String id) async {
    setState(() => _tasks.removeWhere((task) => task['id'] == id));
    await _saveTasks();
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'manabixx-planner-note-${_today}',
      _noteController.text,
    );
    if (mounted) setState(() => _noteSaved = true);
  }

  Future<void> _saveFocusCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'manabixx-focus-count-${_today}',
      _focusCount.toString(),
    );
  }

  void _setMinutes(int value) {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _minutes = value;
      _remaining = value * 60;
    });
  }

  void _startTimer() {
    if (_timer != null || _remaining == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _focusCount++;
          _timer = null;
        });
        _saveFocusCount();
      } else {
        setState(() => _remaining--);
      }
    });
    setState(() {});
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _remaining = _minutes * 60;
    });
  }

  void _moveCard(int delta) {
    if (_questions.isEmpty) return;
    setState(() {
      _cardIndex = (_cardIndex + delta + _questions.length) % _questions.length;
      _flipped = false;
    });
  }

  String _subjectLabel(Object? subject) => switch (subject) {
        'science' => '理科',
        'social' => '社会',
        'math' => '数学',
        'english' => '英語',
        'japanese' => '国語',
        _ => 'その他',
      };

  Widget _heading(String eyebrow, String title, String description) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow,
                style: const TextStyle(
                    color: Color(0xFFFF7900),
                    fontSize: 10,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(description,
                style: const TextStyle(
                    color: Color(0xFF9999A1), fontSize: 12, height: 1.7)),
          ],
        ),
      );

  Widget _metric(String label, String value, String detail, IconData icon) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFFFF7900), size: 19),
              const SizedBox(height: 9),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF9999A1),
                      fontSize: 9,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
              Text(detail,
                  style: const TextStyle(
                      color: Color(0xFF9999A1), fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _overview() => Builder(builder: (context) {
        final tabs = DefaultTabController.of(context);
        return LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth < 560
              ? (constraints.maxWidth - 10) / 2
              : (constraints.maxWidth - 20) / 3;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _heading('YOUR DAY', '今日の学習状況',
                  '計画・集中・復習を、この端末の中でまとめて管理します。'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: _metric('TODAY TASKS', '$_done/${_todayTasks.length}',
                        '完了したタスク', Icons.check_circle_outline_rounded),
                  ),
                  SizedBox(
                    width: width,
                    child: _metric('FOCUS SESSIONS', '$_focusCount',
                        '今日完了した集中時間', Icons.timer_outlined),
                  ),
                  SizedBox(
                    width: width,
                    child: _metric('FLASHCARDS', '${_questions.length}',
                        '読み込んだ4択問題', Icons.style_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('今日やること',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      if (_todayTasks.isEmpty)
                        const Text('まずは小さなタスクを一つ追加しましょう。',
                            style: TextStyle(
                                color: Color(0xFF9999A1), fontSize: 12))
                      else
                        ..._todayTasks.take(4).map((task) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(children: [
                                Icon(
                                  task['done'] == true
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 17,
                                  color: task['done'] == true
                                      ? const Color(0xFFFF7900)
                                      : const Color(0xFF77777F),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    task['title']?.toString() ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      decoration: task['done'] == true
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                Text(_subjectLabel(task['subject']),
                                    style: const TextStyle(
                                        color: Color(0xFF9999A1),
                                        fontSize: 10)),
                              ]),
                            )),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => tabs.animateTo(1),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('学習計画を編集'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Color(0xFFFF7900), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('まずは一つに集中',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 15)),
                            Text('現在の設定：$_minutes分',
                                style: const TextStyle(
                                    color: Color(0xFF9999A1), fontSize: 11)),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => tabs.animateTo(2),
                        child: const Text('始める'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '学習計画・メモ・集中回数はこのブラウザー内に保存されます。端末やブラウザーをまたいだ同期は行いません。',
                style: TextStyle(
                    color: Color(0xFF77777F), fontSize: 10, height: 1.7),
              ),
            ],
          );
        });
      });

  Widget _tasksView() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _heading('DAILY PLANNER', '今日の学習計画',
              'やることを小さく分けて、終わったらチェックしましょう。'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    key: const Key('workspace-task-input'),
                    controller: _taskController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTask(),
                    decoration: const InputDecoration(
                      labelText: 'タスク名',
                      hintText: '例：理科の電流を20問解く',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _subject,
                          decoration: const InputDecoration(
                              labelText: '教科', border: OutlineInputBorder()),
                          items: const ['理科', '社会', '数学', '英語', '国語', 'その他']
                              .map((name) => DropdownMenuItem(
                                  value: name, child: Text(name)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _subject = value ?? '理科'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _minutes,
                          decoration: const InputDecoration(
                              labelText: '予定時間',
                              border: OutlineInputBorder()),
                          items: const [15, 25, 45, 60]
                              .map((minutes) => DropdownMenuItem(
                                  value: minutes,
                                  child: Text('${minutes}分')))
                              .toList(),
                          onChanged: (value) => _setMinutes(value ?? 25),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('workspace-add-task'),
                      onPressed: _addTask,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('タスクを追加'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Text('今日のタスク',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              Text('$_done/${_todayTasks.length} 完了',
                  style: const TextStyle(
                      color: Color(0xFF9999A1), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          if (_todayTasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('タスクはまだありません。最初の一つを追加しましょう。',
                    style:
                        TextStyle(color: Color(0xFF9999A1), fontSize: 12)),
              ),
            )
          else
            ..._todayTasks.map((task) {
              final id = task['id']?.toString() ?? '';
              final done = task['done'] == true;
              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: done,
                    onChanged: (_) => _toggleTask(id),
                  ),
                  title: Text(
                    task['title']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? const Color(0xFF9999A1) : null,
                    ),
                  ),
                  subtitle: Text(
                    '${_subjectLabel(task['subject'])} · ${task['minutes'] ?? 25}分',
                    style: const TextStyle(
                        color: Color(0xFF9999A1), fontSize: 10),
                  ),
                  trailing: IconButton(
                    tooltip: 'タスクを削除',
                    onPressed: () => _deleteTask(id),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              );
            }),
        ],
      );

  Widget _focusView() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _heading('DEEP FOCUS', '集中タイマー',
              '時間を決めて、一つの課題に取り組みましょう。'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
              child: Column(
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFF7900), width: 5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_clock,
                              style: const TextStyle(
                                  fontSize: 43, fontWeight: FontWeight.w900)),
                          Text(
                            _timer == null ? 'READY TO FOCUS' : 'FOCUSING',
                            style: const TextStyle(
                                color: Color(0xFF9999A1),
                                fontSize: 9,
                                letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [15, 25, 45, 60]
                        .map((minutes) => ChoiceChip(
                              label: Text('${minutes}分'),
                              selected: _minutes == minutes,
                              onSelected: (_) => _setMinutes(minutes),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      if (_timer == null)
                        FilledButton.icon(
                          onPressed: _remaining == 0 ? null : _startTimer,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('スタート'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _pauseTimer,
                          icon: const Icon(Icons.pause_rounded),
                          label: const Text('一時停止'),
                        ),
                      OutlinedButton.icon(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('リセット'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('今日の完了セッション：$_focusCount回',
                      style: const TextStyle(
                          color: Color(0xFF9999A1), fontSize: 11)),
                  const SizedBox(height: 8),
                  const Text(
                    'タイマーはこの画面を開いている間に動作します。画面を閉じると停止します。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF77777F), fontSize: 10, height: 1.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _cardsView() {
    if (_loadingQuestions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_questionError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('暗記カードを読み込めませんでした。\n$_questionError',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF9999A1), fontSize: 12, height: 1.8)),
        ),
      );
    }
    if (_questions.isEmpty) {
      return const Center(
          child: Text('利用できる4択問題がありません。',
              style: TextStyle(color: Color(0xFF9999A1))));
    }
    final question = _questions[_cardIndex];
    final options = (question['options'] as List).cast<dynamic>();
    final correct = question['correct'] as int;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _heading('ACTIVE RECALL', '暗記カード',
            '問題を見て答えを考えてから、カードを裏返しましょう。'),
        Row(
          children: [
            Text('${_subjectLabel(question['subject'])} · ${_cardIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                    color: Color(0xFF9999A1), fontSize: 11)),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _flipped = !_flipped),
              child: Text(_flipped ? '問題に戻る' : '答えを見る'),
            ),
          ],
        ),
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _flipped = !_flipped),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 240),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_flipped ? 'ANSWER / 解答' : 'QUESTION / 問題',
                        style: const TextStyle(
                            color: Color(0xFFFF7900),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 18),
                    Text(
                      _flipped
                          ? options[correct].toString()
                          : question['prompt'].toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.7),
                    ),
                    if (_flipped) ...[
                      const SizedBox(height: 14),
                      Text(
                        question['explanation']?.toString() ?? '解説はありません。',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFB7B7BE),
                            fontSize: 12,
                            height: 1.8),
                      ),
                    ] else ...[
                      const SizedBox(height: 18),
                      const Text('タップして答えを確認',
                          style: TextStyle(
                              color: Color(0xFF9999A1), fontSize: 11)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _moveCard(-1),
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('前へ'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _moveCard(1),
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('次のカード'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notesView() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _heading('QUICK NOTES', '今日の学習メモ',
              '分かったこと、間違えた理由、次に復習することを書き残します。'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOTE · $_today',
                      style: const TextStyle(
                          color: Color(0xFFFF7900),
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('workspace-note-input'),
                    controller: _noteController,
                    enabled: _ready,
                    minLines: 12,
                    maxLines: 20,
                    onChanged: (_) => setState(() => _noteSaved = false),
                    decoration: const InputDecoration(
                      hintText: '今日わかったこと、まだ曖昧なところ、次に復習すること…',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          !_ready
                              ? '読み込み中'
                              : _noteSaved
                                  ? '保存済み'
                                  : '未保存の変更があります',
                          style: const TextStyle(
                              color: Color(0xFF9999A1), fontSize: 11),
                        ),
                      ),
                      FilledButton.icon(
                        key: const Key('workspace-save-note'),
                        onPressed: _ready ? _saveNote : null,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('メモを保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('学習ワークスペース'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.dashboard_outlined), text: '概要'),
                Tab(icon: Icon(Icons.checklist_rounded), text: '学習計画'),
                Tab(icon: Icon(Icons.timer_outlined), text: '集中タイマー'),
                Tab(icon: Icon(Icons.style_outlined), text: '暗記カード'),
                Tab(icon: Icon(Icons.note_alt_outlined), text: '学習メモ'),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: TabBarView(
                  children: [
                    _overview(),
                    _tasksView(),
                    _focusView(),
                    _cardsView(),
                    _notesView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
