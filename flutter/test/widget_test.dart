import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_web/foundation_practice.dart';
import 'package:manabixx_web/kosen_practice.dart';
import 'package:manabixx_web/knowledge_library.dart';
import 'package:manabixx_web/main.dart';

Future<void> prepareViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the Flutter migration preview and foundation entry point', (tester) async {
    await prepareViewport(tester);
    await tester.pumpWidget(const ManabiXXApp());

    expect(find.text('MANABIXX'), findsOneWidget);
    expect(find.text('Flutter Web preview'), findsOneWidget);
    expect(find.text('基礎網羅問題を開く'), findsOneWidget);
    expect(find.text('公開サイトの切替'), findsOneWidget);
  });

  testWidgets('loads existing foundation questions and completes a session', (tester) async {
    const question = FoundationQuestion(
      id: 'test-science-001',
      subject: 'science',
      topic: '物理・力',
      level: '基礎',
      prompt: '力の大きさを測定する器具はどれか。',
      options: ['温度計', 'ばねばかり', 'メスシリンダー', '電流計'],
      correct: 1,
      explanation: 'ばねばかりは力の大きさを測定する器具。',
    );

    await prepareViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: FoundationPracticePage(loadQuestions: () async => [question]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('収録問題'), findsOneWidget);
    expect(find.text('1問'), findsOneWidget);
    await tapVisible(tester, find.text('演習を始める'));

    expect(find.text(question.prompt), findsOneWidget);
    await tapVisible(tester, find.text('B. ばねばかり'));

    expect(find.text('正解！'), findsOneWidget);
    expect(find.text(question.explanation), findsOneWidget);
    await tapVisible(tester, find.text('結果を見る'));

    expect(find.text('演習完了'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
  });

  testWidgets('uses the public entrance exam dataset and shows source status', (tester) async {
    const question = FoundationQuestion(
      id: 'test-exam-001',
      subject: 'science',
      topic: '物理・運動',
      level: '公立入試標準',
      prompt: '平均の速さを求める式はどれか。',
      options: ['道のり÷時間', '時間÷道のり', '道のり×時間', '道のり＋時間'],
      correct: 0,
      explanation: '平均の速さは道のりを時間で割って求める。',
      sourceLabel: '出典照合中',
      sourceNote: '原資料との照合を進めています。',
    );

    await prepareViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: FoundationPracticePage(
          dataPath: 'data/public-exam.json',
          title: '公立高校入試問題',
          loadQuestions: () async => [question],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('公立高校入試問題'), findsWidgets);
    await tapVisible(tester, find.text('演習を始める'));

    expect(find.text(question.prompt), findsOneWidget);
    expect(find.text('出典照合中'), findsOneWidget);
    expect(find.text(question.sourceNote), findsOneWidget);
  });

  testWidgets('allows all five subjects in mock exam mode', (tester) async {
    const question = FoundationQuestion(
      id: 'mock-japanese-001',
      subject: 'japanese',
      topic: '漢字',
      level: '標準',
      prompt: '「責任」の読み方はどれか。',
      options: ['せきにん', 'せきじん', 'せっにん', 'せきねん'],
      correct: 0,
      explanation: '「責任」は「せきにん」と読む。',
    );

    await prepareViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: FoundationPracticePage(
          dataPath: 'data/mock-exams.json',
          title: '模試・予想問題',
          includeAllSubjects: true,
          loadQuestions: () async => [question],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('模試・予想問題'), findsWidgets);
    expect(find.text('1問'), findsOneWidget);
    await tapVisible(tester, find.byType(DropdownButtonFormField<String>).first);
    expect(find.text('国語'), findsOneWidget);
    await tapVisible(tester, find.text('国語').last);
    expect(find.text('1問'), findsOneWidget);
  });

  testWidgets('searches and opens knowledge library records', (tester) async {
    const record = KnowledgeRecord(
      id: 'science-density-001',
      subject: 'science',
      grade: 1,
      field: '化学',
      title: '密度',
      status: 'authored',
      explanation: '密度は物質1cm³あたりの質量。',
      formulas: ['密度＝質量÷体積'],
      keyTerms: ['質量', '体積'],
    );
    await prepareViewport(tester);
    await tester.pumpWidget(MaterialApp(
      home: KnowledgeLibraryPage(loadRecords: () async => [record]),
    ));
    await tester.pumpAndSettle();
    expect(find.text('密度'), findsOneWidget);
    await tester.tap(find.text('密度'));
    await tester.pumpAndSettle();
    expect(find.text('密度＝質量÷体積'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '地理');
    await tester.pumpAndSettle();
    expect(find.text('条件に一致する教材がありません。'), findsOneWidget);
  });

  testWidgets('loads isolated practice data and completes a session', (tester) async {
    const question = KosenQuestion(
      id: 'test-math-001',
      subject: 'math',
      topic: '一次関数',
      level: '基礎',
      prompt: '3x - 2 = 10 のとき、x はいくつか。',
      options: ['2', '3', '4', '5'],
      correct: 2,
      explanation: '3x = 12 なので x = 4。',
    );

    await prepareViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: KosenPracticePage(loadQuestions: () async => [question]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('対象問題：1問'), findsOneWidget);
    await tapVisible(tester, find.text('演習を始める'));

    expect(find.text(question.prompt), findsOneWidget);
    await tapVisible(tester, find.text('4'));

    expect(find.text('正解！'), findsOneWidget);
    expect(find.text(question.explanation), findsOneWidget);
    await tapVisible(tester, find.text('結果を見る'));

    expect(find.text('演習完了'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
  });
}
