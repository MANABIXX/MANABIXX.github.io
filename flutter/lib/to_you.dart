import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const _motivationBlogUrl = 'https://manabixx.github.io/blog/';

class ToYouPage extends StatelessWidget {
  const ToYouPage({super.key});

  Future<List<Map<String, dynamic>>> _load() async {
    final response = await http.get(Uri.base.resolve('/data/to-you.json'));
    if (response.statusCode != 200) throw Exception('記事データを読み込めませんでした。');
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['articles'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('君へ')),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: OutlinedButton.icon(
        onPressed: () async {
          final opened = await launchUrl(
            Uri.parse(_motivationBlogUrl),
            mode: LaunchMode.externalApplication,
          );
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('記事サイトを開けませんでした。')),
            );
          }
        },
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('学習習慣・モチベーション記事を読む'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
      ),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return const Center(child: Text('メッセージを読み込めませんでした。'));
        final articles = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            const Text('A LETTER FOR YOU', style: TextStyle(color: Color(0xFFFF7900), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('今日の君へ。', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('調子のいい日も、うまくいかない日も。ここに戻ってきていい。', style: TextStyle(color: Colors.white70, height: 1.6)),
            const SizedBox(height: 20),
            ...articles.map((article) => Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text((article['tag'] as String? ?? 'MESSAGE').toUpperCase(), style: const TextStyle(color: Color(0xFFFF7900), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(article['title'] as String? ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.4)),
                  const SizedBox(height: 12),
                  Text(article['body'] as String? ?? '', style: const TextStyle(fontSize: 14, height: 1.9, color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text(article['date'] as String? ?? '', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ]),
              ),
            )),
          ],
        );
      },
    ),
  );
}