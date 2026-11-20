import 'package:material_ui/material_ui.dart';

class FeedbackPausedPage extends StatelessWidget {
  const FeedbackPausedPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('意見受付停止中')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(
                    Icons.pause_circle_outline_rounded,
                    size: 48,
                    color: Color(0xFFFF7900),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '意見受付は一時停止中です。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '送信機能は現在利用できません',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '意見を安全に保存する方法を整えるまで、受付を停止しています。'
                            'この画面では入力・送信・下書き保存を行いません。',
                            style: TextStyle(
                              color: Color(0xFFB7B7BE),
                              height: 1.8,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/releases'),
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('更新履歴を見る'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('ホームへ戻る'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
