import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_web/workspace.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> _sampleQuestions() async => [
      {
        'id': 'workspace-card-1',
        'subject': 'science',
        'prompt': '力の大きさを測る器具はどれか。',
        'options': ['温度計', 'ばねばかり', '電流計', 'メスシリンダー'],
        'correct': 1,
        'explanation': 'ばねばかりは力の大きさを測定します。',
      },
      {
        'id': 'workspace-card-2',
        'subject': 'social',
        'prompt': '日本の標準時子午線が通る市はどこか。',
        'options': ['京都市', '神戸市', '明石市', '大阪市'],
        'correct': 2,
        'explanation': '東経135度の子午線が兵庫県明石市を通ります。',
      },
    ];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('saves tasks and notes with the previous workspace keys',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(MaterialApp(
      home: WorkspacePage(loadQuestions: _sampleQuestions),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('学習計画'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('workspace-task-input')), '理科の電流を10問解く');
    await tester.tap(find.byKey(const Key('workspace-add-task')));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('manabixx-planner-tasks-v1')!);
    expect(stored.first['title'], '理科の電流を10問解く');

    await tester.tap(find.text('学習メモ'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('workspace-note-input')), 'オームの法則を復習する');
    await tester.tap(find.byKey(const Key('workspace-save-note')));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final key =
        'manabixx-planner-note-${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    expect(prefs.getString(key), 'オームの法則を復習する');
    tester.view.resetPhysicalSize();
  });

  testWidgets('reveals answers and moves through question-backed flashcards',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(MaterialApp(
      home: WorkspacePage(loadQuestions: _sampleQuestions),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('暗記カード'));
    await tester.pumpAndSettle();
    expect(find.text('力の大きさを測る器具はどれか。'), findsOneWidget);
    await tester.tap(find.text('答えを見る'));
    await tester.pumpAndSettle();
    expect(find.text('ばねばかり'), findsOneWidget);
    expect(find.text('ばねばかりは力の大きさを測定します。'), findsOneWidget);
    await tester.tap(find.text('次のカード'));
    await tester.pumpAndSettle();
    expect(find.text('日本の標準時子午線が通る市はどこか。'), findsOneWidget);
    tester.view.resetPhysicalSize();
  });
}
