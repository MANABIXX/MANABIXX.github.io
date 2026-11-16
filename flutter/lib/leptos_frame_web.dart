import 'dart:ui_web' as ui_web;

import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

const _viewType = 'manabixx-leptos-knowledge-library';
bool _registered = false;

Widget buildLeptosFrame() {
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
  return const HtmlElementView(viewType: _viewType);
}
