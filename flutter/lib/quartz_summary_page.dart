import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class QuartzSummaryPage extends StatelessWidget {
  const QuartzSummaryPage({super.key, this.initialSubject = 'science'});
  final String initialSubject;

  Future<void> _open(BuildContext context, String subject) async {
    final uri = Uri.base.resolve(subject.isEmpty ? '/summary/' : '/summary/$subject/');
    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('要点まとめを開けませんでした。')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('要点まとめ')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('知識をつなげて理解する', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('分野別の要点・重要語句・公式・図解をまとめた学習ライブラリです。全文検索、関連ページ、知識グラフを利用できます。'),
      const SizedBox(height: 20),
      _QuartzSubjectCard(title: '理科', subtitle: '物理・化学・生物・地学', icon: Icons.science_outlined, onTap: () => _open(context, 'science')),
      const SizedBox(height: 12),
      _QuartzSubjectCard(title: '社会', subtitle: '地理・歴史・公民', icon: Icons.public_outlined, onTap: () => _open(context, 'social')),
      const SizedBox(height: 12),
      _QuartzSubjectCard(title: 'すべての要点まとめ', subtitle: '全文検索・知識グラフ・関連ページ', icon: Icons.account_tree_outlined, onTap: () => _open(context, '')),
    ]),
  );
}

class _QuartzSubjectCard extends StatelessWidget {
  const _QuartzSubjectCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    leading: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.open_in_new),
    onTap: onTap,
  ));
}
