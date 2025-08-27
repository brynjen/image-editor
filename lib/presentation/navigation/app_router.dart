import 'package:go_router/go_router.dart';

import '../screen/image_editor_screen.dart';

/// Application router configuration
class AppRouter {
  static const String imageEditor = '/';

  static final GoRouter router = GoRouter(
    initialLocation: imageEditor,
    routes: [
      GoRoute(
        path: imageEditor,
        builder: (context, state) => const ImageEditorScreen(),
      ),
    ],
  );
}
