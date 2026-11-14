import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_web/foundation_practice.dart';
import 'package:manabixx_web/kosen_practice.dart';
import 'package:manabixx_web/main.dart';

void main() {
  testWidgets('renders the Flutter migration preview and foundation entry point', (tester) async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: FoundationPracticePage(loadQuestions: () async => [question]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('収録問題'), findsOneWidget);
    expect(find.text('1問'), findsOneWidget);
    await tester.tap(find.text('演習を始める'));
    await tester.pumpAndSettle();

    expect(find.text(question.prompt), findsOneWidget);
    await tester.tap(find.text('B. ばねばかり'));
    await tester.pumpAndSettle();

    expect(find.text('正解！'), findsOneWidget);
    expect(find.text(question.explanation), findsOneWidget);
    await tester.tap(find.text('結果を見る'));
    await tester.pumpAndSettle();

    expect(find.text('演習完了'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
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

    await tester.pumpWidget(
      MaterialApp(
        home: KosenPracticePage(loadQuestions: () async => [question]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('対象問題：1問'), findsOneWidget);
    await tester.tap(find.text('演習を始める'));
    await tester.pumpAndSettle();

    expect(find.text(question.prompt), findsOneWidget);
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    expect(find.text('正解！'), findsOneWidget);
    expect(find.text(question.explanation), findsOneWidget);
    await tester.tap(find.text('結果を見る'));
    await tester.pumpAndSettle();

    expect(find.text('演習完了'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
  });
}
