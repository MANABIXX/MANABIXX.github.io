import 'package:flutter_test/flutter_test.dart';
import 'package:manabixx_web/main.dart';

void main() {
  testWidgets('renders the migration preview without replacing production', (tester) async {
    await tester.pumpWidget(const ManabiXXApp());

    expect(find.text('MANABIXX'), findsOneWidget);
    expect(find.text('Flutter Web preview'), findsOneWidget);
    expect(find.text('公開サイトの切替'), findsOneWidget);
  });
}
