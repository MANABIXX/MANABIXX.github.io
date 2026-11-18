import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:manabixx_web/foundation_practice.dart';

const _subjects = ['japanese', 'math', 'english', 'science', 'social'];

List<FoundationQuestion> _questions({int perSubject = 12}) {
  return [
    for (final subject in _subjects)
      for (var i = 0; i < perSubject; i++)
        FoundationQuestion(
          id: '$subject-$i',
          subject: subject,
          topic: 'test',
          level: '基礎',
          prompt: '$subject question $i',
          options: const ['A', 'B', 'C', 'D'],
          correct: 0,
          explanation: 'test explanation',
        ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('balanced selection returns ten unique questions per subject', () {
    final selected = selectBalancedQuestions(_questions(), random: Random(7));
    expect(selected, hasLength(50));
    expect(selected.map((question) => question.id).toSet(), hasLength(50));

    final counts = <String, int>{};
    for (final question in selected) {
      counts.update(question.subject, (value) => value + 1, ifAbsent: () => 1);
    }
    expect(counts, {
      'japanese': 10,
      'math': 10,
      'english': 10,
      'science': 10,
      'social': 10,
    });
  });

  testWidgets('下積みモード starts a fixed 5-subject by 10-question session',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: FoundationPracticePage(
          title: '下積みモード',
          includeAllSubjects: true,
          balancedPerSubject: true,
          loadQuestions: () async => _questions(perSubject: 10),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('出題形式：5教科×10問（合計50問）'), findsOneWidget);
    expect(
      find.text('全50問から各教科10問ずつ、合計50問を出題します。'),
      findsOneWidget,
    );

    await tester.tap(find.text('演習を始める'));
    await tester.pumpAndSettle();

    expect(find.text('1/50'), findsOneWidget);
  });
}
