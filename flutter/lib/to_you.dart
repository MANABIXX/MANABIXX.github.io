import 'package:material_ui/material_ui.dart';
import 'leptos_frame_stub.dart'
    if (dart.library.js_interop) 'leptos_frame_web.dart' as leptos_frame;

class ToYouPage extends StatelessWidget {
  const ToYouPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MANABIXXブログ')),
    body: leptos_frame.buildLeptosBlogFrame(),
  );
}
