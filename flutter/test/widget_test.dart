import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_web/kosen_practice.dart';
import 'package:manabixx_web/main.dart';

void main() {
  testWidgets('renders the migration preview without replacing production', (tester) async {
    await tester.pumpWidget(const ManabiXXApp());

    expect(find.text('MANABIXX'), findsOneWidget);
    expect(find.text('Flutter Web preview'), findsOneWidget);
    expect(find.text('公開サイトの切替'), findsOneWidget);
    expect(find.text('高専専用モードを開く'), findsOneWidget);
  });

  testWidgets('loads real-shaped question data and completes a practice session', (tester) async {
    final question = KosenQuestion(
      id: 'test-math-001',
      subject: 'math',
      topic: '一次関数',
      level: '基礎',
      prompt: '3x - 2 = 10 のとき、x はいくつか。',
      options: const ['2', '3', '4', '5'],
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
