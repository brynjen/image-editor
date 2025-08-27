import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/navigation/app_router.dart';
import 'data/repository/serverpod_client_config.dart';
import 'data/repository/serverpod_image_repository.dart';
import 'data/repository/server_status_service.dart';
import 'domain/repository/image_repository.dart';
import 'presentation/bloc/server_status_bloc.dart';
import 'presentation/bloc/server_status_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure window for desktop platforms
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

  // Create Serverpod client and repository
  final client = ServerpodClientConfig.createClient();
  final imageRepository = ServerpodImageRepository(client);
  
  // Create server status service
  final serverStatusService = ServerStatusService(client, '127.0.0.1', 8080);

  runApp(ImageEditorApp(
    imageRepository: imageRepository,
    serverStatusService: serverStatusService,
  ));
}

/// Main application widget
class ImageEditorApp extends StatelessWidget {
  final ImageRepository imageRepository;
  final ServerStatusService serverStatusService;
  
  const ImageEditorApp({
    super.key,
    required this.imageRepository,
    required this.serverStatusService,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ImageRepository>.value(
      value: imageRepository,
      child: BlocProvider(
        create: (context) => ServerStatusBloc(serverStatusService)
          ..add(const ServerStatusMonitoringStarted()),
        child: MaterialApp.router(
          title: 'Image Editor',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          routerConfig: AppRouter.createRouter(imageRepository),
        ),
      ),
    );
  }
}
