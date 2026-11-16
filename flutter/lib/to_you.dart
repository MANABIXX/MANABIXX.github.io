import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

const _motivationBlogUrl = 'https://manabixx.github.io/blog/';

class ToYouPage extends StatelessWidget {
  const ToYouPage({super.key});

  Future<void> _openBlog(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(_motivationBlogUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MANABIXXブログを開けませんでした。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MANABIXXブログ')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MANABIXX BLOG',
                style: TextStyle(color: Color(0xFFFF7900), fontSize: 11,
                  letterSpacing: 2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('学びを続けるための読みもの。',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, height: 1.4)),
              const SizedBox(height: 10),
              const Text(
                '学習習慣や勉強法、モチベーションに関する記事をMANABIXXブログで読めます。',
                style: TextStyle(color: Colors.white70, height: 1.8)),
              const SizedBox(height: 22),
              SizedBox(width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openBlog(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('MANABIXXブログを開く'),
                )),
            ],
          ),
        ),
      ),
    ),
  );
}
