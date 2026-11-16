import 'package:material_ui/material_ui.dart';
import 'leptos_frame_stub.dart'
    if (dart.library.js_interop) 'leptos_frame_web.dart' as leptos_frame;

class LeptosKnowledgePage extends StatelessWidget {
  const LeptosKnowledgePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('要点まとめ')),
    body: leptos_frame.buildLeptosFrame(),
  );
}
