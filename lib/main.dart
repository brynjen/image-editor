import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/navigation/app_router.dart';
import 'data/repository/app_config_service.dart';
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

  // Initialize app configuration service
  final appConfigService = AppConfigService();
  await appConfigService.initialize();

  runApp(ImageEditorApp(
    appConfigService: appConfigService,
  ));
}

/// Main application widget
class ImageEditorApp extends StatelessWidget {
  final AppConfigService appConfigService;
  
  const ImageEditorApp({
    super.key,
    required this.appConfigService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appConfigService,
      child: Consumer<AppConfigService>(
        builder: (context, configService, child) {
          final imageRepository = configService.imageRepository;
          final serverStatusService = configService.serverStatusService;
          
          if (imageRepository == null || serverStatusService == null) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          
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
        },
      ),
    );
  }
}
