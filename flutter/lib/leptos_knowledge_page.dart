import 'dart:ui_web' as ui_web;

import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

class LeptosKnowledgePage extends StatefulWidget {
  const LeptosKnowledgePage({super.key});

  @override
  State<LeptosKnowledgePage> createState() => _LeptosKnowledgePageState();
}

class _LeptosKnowledgePageState extends State<LeptosKnowledgePage> {
  static const _viewType = 'manabixx-leptos-knowledge-library';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final frame = web.HTMLIFrameElement()
          ..src = '/knowledge/'
          ..title = 'MANABIXX 知識ライブラリ'
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%';
        return frame;
      });
      _registered = true;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('要点まとめ')),
    body: const HtmlElementView(viewType: _viewType),
  );
}
