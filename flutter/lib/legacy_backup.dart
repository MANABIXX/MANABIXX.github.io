import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegacyBackupPage extends StatefulWidget {
  const LegacyBackupPage({super.key});

  @override
  State<LegacyBackupPage> createState() => _LegacyBackupPageState();
}

class _LegacyBackupPageState extends State<LegacyBackupPage> {
  bool _busy = false;
  String? _message;

  Future<void> _exportBackup() async {
    setState(() { _busy = true; _message = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList()..sort();
      final entries = keys.map((key) => <String, dynamic>{
        'key': key,
        'value': prefs.get(key),
      }).toList();
      final backup = <String, dynamic>{
        'format_version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'entries': entries,
      };
      final json = const JsonEncoder.withIndent('  ').convert(backup);
      final blob = web.Blob(
        <JSAny>[json.toJS].toJS,
        web.BlobPropertyBag(type: 'application/json'),
      );
      final objectUrl = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = objectUrl
        ..download = 'manabixx-backup-${DateTime.now().toIso8601String().substring(0, 10)}.json';
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(objectUrl);
      if (mounted) setState(() {
        _message = '${entries.length}件の保存データをJSONに書き出しました。元データは削除していません。';
      });
    } catch (error) {
      if (mounted) {
        setState(() { _message = 'バックアップに失敗しました: $error'; });
      }
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('学習データのバックアップ')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Icon(Icons.shield_outlined, size: 48, color: Color(0xFFFF7900)),
      const SizedBox(height: 16),
      const Text('再構築前にデータを守る',
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('学習履歴、苦手問題、学習計画、メモ、集中回数など、SharedPreferencesに保存されている全キーをJSONに書き出します。データはサーバーへ送信されません。'),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: _busy ? null : _exportBackup,
        icon: const Icon(Icons.download_rounded),
        label: Text(_busy ? '書き出し中…' : 'バックアップJSONを書き出す'),
      ),
      if (_message != null) ...[
        const SizedBox(height: 16),
        SelectableText(_message!, style: const TextStyle(color: Color(0xFFB8C7D9))),
      ],
      const SizedBox(height: 24),
      const Text('重要', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFFB36B))),
      const SizedBox(height: 6),
      const Text('この機能はバックアップの書き出しのみです。既存データの削除・移動・SQLiteへの切り替えは行いません。JSONファイルは自分で安全な場所に保管してください。'),
    ]),
  );
}
