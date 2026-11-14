import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

class KnowledgeRecord {
  const KnowledgeRecord({
    required this.id,
    required this.subject,
    required this.grade,
    required this.field,
    required this.title,
    required this.status,
    this.explanation = '',
    this.targets = const [],
    this.keyTerms = const [],
    this.formulas = const [],
    this.questionPatterns = const [],
    this.commonErrors = const [],
  });

  final String id, subject, field, title, status, explanation;
  final int grade;
  final List<String> targets, keyTerms, formulas, questionPatterns, commonErrors;

  factory KnowledgeRecord.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) => (json[key] as List<dynamic>? ?? [])
        .whereType<String>().toList(growable: false);
    final terms = ((json['keyTerms'] ?? json['terms']) as List<dynamic>? ?? []).map((term) {
      if (term is String) return term;
      if (term is List && term.isNotEmpty) return term.map((v) => '$v').join('：');
      return '';
    }).where((term) => term.isNotEmpty).toList(growable: false);
    return KnowledgeRecord(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      grade: json['grade'] as int? ?? 0,
      field: json['field'] as String? ?? '',
      title: json['title'] as String? ?? '名称未設定',
      status: json['status'] as String? ?? 'outline',
      explanation: json['explanation'] as String? ?? '',
      targets: strings('targets'),
      keyTerms: terms,
      formulas: strings('formulas').isNotEmpty ? strings('formulas') : (json['formula'] is String ? [json['formula'] as String] : []),
      questionPatterns: strings('questionPatterns').isNotEmpty ? strings('questionPatterns') : strings('questions'),
      commonErrors: strings('commonErrors').isNotEmpty ? strings('commonErrors') : strings('errors'),
    );
  }
}

class KnowledgeLibraryPage extends StatefulWidget {
  const KnowledgeLibraryPage({super.key, this.loadRecords, this.title = '要点まとめ', this.initialSubject = 'science'});
  final Future<List<KnowledgeRecord>> Function()? loadRecords;
  final String title;
  final String initialSubject;

  @override
  State<KnowledgeLibraryPage> createState() => _KnowledgeLibraryPageState();
}

class _KnowledgeLibraryPageState extends State<KnowledgeLibraryPage> {
  List<KnowledgeRecord> _records = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  late String _subject = widget.initialSubject;
  String _grade = 'all';
  String _field = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<List<KnowledgeRecord>> _fetch() async {
    final uri = Uri.base.resolve('/data/knowledge-base.json');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('教材データを読み込めませんでした（HTTP ${response.statusCode}）。');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final topics = (payload['topicRecords'] as List<dynamic>? ?? [])
        .map((item) => KnowledgeRecord.fromJson(item as Map<String, dynamic>));
    final authored = (payload['authoredModules'] as List<dynamic>? ?? [])
        .map((item) => KnowledgeRecord.fromJson(item as Map<String, dynamic>));
    return [...topics, ...authored].where((item) => item.id.isNotEmpty).toList();
  }

  Future<void> _load() async {
    try {
      final records = await (widget.loadRecords ?? _fetch)();
      if (!mounted) return;
      setState(() { _records = records; _loading = false; _error = null; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error.toString(); _loading = false; });
    }
  }

  List<String> get _fields => _records
      .where((r) => (r.subject == 'science' || r.subject == 'social') && r.subject == _subject)
      .map((r) => r.field).where((f) => f.isNotEmpty).toSet().toList()..sort();

  List<KnowledgeRecord> get _shown => _records.where((r) {
    final text = [r.title, r.field, r.explanation, ...r.keyTerms, ...r.targets]
        .join(' ').toLowerCase();
    return (r.subject == 'science' || r.subject == 'social') && r.subject == _subject &&
        (_grade == 'all' || r.grade.toString() == _grade) &&
        (_field == 'all' || r.field == _field) &&
        (_query.isEmpty || text.contains(_query.toLowerCase()));
  }).toList(growable: false);

  String _subjectName(String value) => const {'science':'理科','social':'社会','japanese':'国語','math':'数学','english':'英語','civics':'公民','history':'歴史','geography':'地理'}[value] ?? value;
  String _fieldName(String value) => const {'civics':'公民','history':'歴史','geography':'地理','physics':'物理','chemistry':'化学','biology':'生物','earth science':'地学','earth':'地学'}[value.toLowerCase()] ?? value;
  String _gradeName(int value) => value == 0 ? '学年共通' : '中学$value年';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!), const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('再読み込み')),
                ]))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_subject == 'science' ? '理科の重要ポイント' : '社会の重要ポイント', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${_shown.length}件の単元を分野別に確認できます。', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: '単元名・用語・内容から検索', border: OutlineInputBorder()),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 4, children: [
                        SizedBox(width: 145, child: DropdownButtonFormField<String>(
                          initialValue: _subject, decoration: const InputDecoration(labelText: '教科'),
                          items: const [
                            DropdownMenuItem(value: 'science', child: Text('理科')),
                            DropdownMenuItem(value: 'social', child: Text('社会')),
                          ],
                          onChanged: (v) => setState(() { _subject = v ?? 'all'; _field = 'all'; }),
                        )),
                        SizedBox(width: 145, child: DropdownButtonFormField<String>(
                          initialValue: _grade, decoration: const InputDecoration(labelText: '学年'),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('全学年')),
                            DropdownMenuItem(value: '1', child: Text('中学1年')),
                            DropdownMenuItem(value: '2', child: Text('中学2年')),
                            DropdownMenuItem(value: '3', child: Text('中学3年')),
                          ],
                          onChanged: (v) => setState(() => _grade = v ?? 'all'),
                        )),
                        SizedBox(width: 170, child: DropdownButtonFormField<String>(
                          initialValue: _fields.contains(_field) ? _field : 'all',
                          decoration: const InputDecoration(labelText: '分野'),
                          items: [const DropdownMenuItem(value: 'all', child: Text('すべての分野')),
                            ..._fields.map((f) => DropdownMenuItem(value: f, child: Text(_fieldName(f))))],
                          onChanged: (v) => setState(() => _field = v ?? 'all'),
                        )),
                      ]),
                      const SizedBox(height: 8),
                      Text('${_shown.length}件を表示', style: Theme.of(context).textTheme.labelMedium),
                    ]),
                  ),
                  Expanded(child: _shown.isEmpty
                      ? const Center(child: Text('条件に一致する教材がありません。'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _shown.length,
                          itemBuilder: (context, index) {
                            final item = _shown[index];
                            final authored = item.status == 'authored';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ExpansionTile(
                                leading: Icon(item.subject == 'science' ? Icons.science_outlined : Icons.public),
                                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                subtitle: Text('${_subjectName(item.subject)} · ${_gradeName(item.grade)} · ${_fieldName(item.field)} · ${authored ? '解説付き教材' : '単元索引'}'),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                  if (item.explanation.isNotEmpty) _section('概要', item.explanation),
                                  if (item.targets.isNotEmpty) _section('学習目標', item.targets.join('・')),
                                  if (item.keyTerms.isNotEmpty) _termSection(item.keyTerms),
                                  if (item.formulas.isNotEmpty) _formulaSection(item.formulas),
                                  if (item.commonErrors.isNotEmpty) _section('間違えやすいポイント', item.commonErrors.join('\n')),
                                  if (item.questionPatterns.isNotEmpty) _section('よく問われる視点', item.questionPatterns.join('\n')),
                                  if (item.explanation.isEmpty && item.keyTerms.isEmpty && item.targets.isEmpty)
                                    const Align(alignment: Alignment.centerLeft, child: Text('詳細ノートは準備中です。単元の索引として利用できます。')),
                                ],
                              ),
                            );
                          },
                        )),
                ]),
    );
  }

  Widget _section(String title, String body) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF29292F),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF55515A)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFFB15C))),
      const SizedBox(height: 7),
      Text(body, style: const TextStyle(height: 1.75)),
    ]),
  );

  Widget _termSection(List<String> terms) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF202B34),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF405363)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('重要語句', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9ED4FF))),
      const SizedBox(height: 10),
      Wrap(spacing: 7, runSpacing: 7, children: terms.map((term) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFF344A5A), borderRadius: BorderRadius.circular(9)),
        child: Text(term, style: const TextStyle(fontWeight: FontWeight.w700)),
      )).toList()),
    ]),
  );

  Widget _formulaSection(List<String> formulas) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF332719),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF8A5A2B), width: 1.2),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('重要公式・関係', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFFBD78))),
      const SizedBox(height: 9),
      ...formulas.map((formula) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(formula, style: const TextStyle(fontSize: 16, height: 1.55, fontWeight: FontWeight.w800)),
      )),
    ]),
  );
}
