import 'dart:ui_web' as ui_web;
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

const _knowledgeViewType = 'manabixx-leptos-knowledge-library';
const _blogViewType = 'manabixx-leptos-blog';
bool _knowledgeRegistered = false;
bool _blogRegistered = false;

Widget buildLeptosFrame() {
  if (!_knowledgeRegistered) {
    ui_web.platformViewRegistry.registerViewFactory(_knowledgeViewType, (int viewId) {
      final frame = web.HTMLIFrameElement()
        ..src = '/knowledge/'
        ..title = 'MANABIXX 知識ライブラリ'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      return frame;
    });
    _knowledgeRegistered = true;
  }
  return const HtmlElementView(viewType: _knowledgeViewType);
}

Widget buildLeptosBlogFrame() {
  if (!_blogRegistered) {
    ui_web.platformViewRegistry.registerViewFactory(_blogViewType, (int viewId) {
      final frame = web.HTMLIFrameElement()
        ..src = '/knowledge/?view=blog'
        ..title = 'MANABIXXブログ'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      return frame;
    });
    _blogRegistered = true;
  }
  return const HtmlElementView(viewType: _blogViewType);
}
