import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class LeptosKnowledgePage extends StatelessWidget {
  const LeptosKnowledgePage({super.key});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.base.resolve('/knowledge/');
    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('知識ライブラリを開けませんでした。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('要点まとめ')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('知識をつなげて理解する',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('RustとLeptosで構築した知識ライブラリ。理科・社会の単元検索、分野別の整理、重要事項の確認ができます。'),
        const SizedBox(height: 20),
        Card(child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          leading: Icon(Icons.account_tree_outlined, size: 32,
            color: Theme.of(context).colorScheme.primary),
          title: const Text('知識ライブラリを開く',
            style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('全文検索・理科・社会・重要項目'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _open(context),
        )),
      ],
    ),
  );
}
