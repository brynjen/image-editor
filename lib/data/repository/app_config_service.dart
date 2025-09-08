import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_editor_server_client/image_editor_server_client.dart';
import 'serverpod_client_config.dart';
import 'serverpod_image_repository.dart';
import 'server_status_service.dart';
import '../../domain/repository/image_repository.dart';

/// Service for managing application configuration and client instances
class AppConfigService extends ChangeNotifier {
  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  Client? _client;
  ServerpodImageRepository? _imageRepository;
  ServerStatusService? _serverStatusService;

  String _host = 'localhost';
  int _port = 8080;
  String _scheme = 'http';

  /// Current serverpod client
  Client? get client => _client;
  
  /// Current image repository
  ImageRepository? get imageRepository => _imageRepository;
  
  /// Current server status service
  ServerStatusService? get serverStatusService => _serverStatusService;

  /// Current server configuration
  String get host => _host;
  int get port => _port;
  String get scheme => _scheme;
  String get url => '$_scheme://$_host:$_port';

  /// Initialize the service and load configuration
  Future<void> initialize() async {
    await _loadConfiguration();
    await _createClientInstances();
  }

  /// Reload configuration from SharedPreferences and recreate clients
  Future<void> reloadConfiguration() async {
    await _loadConfiguration();
    await _createClientInstances();
    notifyListeners();
  }

  /// Update configuration and save to SharedPreferences
  Future<void> updateConfiguration({
    required String host,
    required int port,
    required String scheme,
  }) async {
    _host = host;
    _port = port;
    _scheme = scheme;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_service_host', host);
    await prefs.setInt('ai_service_port', port);
    await prefs.setString('ai_service_scheme', scheme);

    // Recreate client instances with new configuration
    await _createClientInstances();
    notifyListeners();
  }

  Future<void> _loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    
    _host = prefs.getString('ai_service_host') ?? 'localhost';
    _port = prefs.getInt('ai_service_port') ?? 8080;
    _scheme = prefs.getString('ai_service_scheme') ?? 'http';
  }

  Future<void> _createClientInstances() async {
    // Dispose old instances
    _serverStatusService?.dispose();

    // Create new client with current configuration
    _client = ServerpodClientConfig.createClient(
      host: _host,
      port: _port,
      secure: _scheme == 'https',
    );

    // Create new repository and services
    _imageRepository = ServerpodImageRepository(_client!);
    _serverStatusService = ServerStatusService(_client!, _host, _port);
  }

  /// Dispose of resources
  @override
  void dispose() {
    _serverStatusService?.dispose();
    super.dispose();
  }
}
