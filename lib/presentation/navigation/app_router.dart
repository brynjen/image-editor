import 'package:go_router/go_router.dart';

import '../../domain/repository/image_repository.dart';
import '../screen/image_editor_screen.dart';

/// Application router configuration
class AppRouter {
  static const String imageEditor = '/';

  static GoRouter createRouter(ImageRepository imageRepository) {
    return GoRouter(
      initialLocation: imageEditor,
      routes: [
        GoRoute(
          path: imageEditor,
          builder: (context, state) => ImageEditorScreen(
            imageRepository: imageRepository,
          ),
        ),
      ],
    );
  }
}
