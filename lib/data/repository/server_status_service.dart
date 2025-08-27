import 'dart:async';
import 'package:image_editor_server_client/image_editor_server_client.dart';

/// Service for checking server connectivity and status
class ServerStatusService {
  final Client _client;
  final String _host;
  final int _port;
  Timer? _statusTimer;
  
  final StreamController<ServerStatus> _statusController = 
      StreamController<ServerStatus>.broadcast();
  
  ServerStatus _currentStatus = ServerStatus.disconnected;
  
  ServerStatusService(this._client, this._host, this._port);
  
  /// Stream of server status changes
  Stream<ServerStatus> get statusStream => _statusController.stream;
  
  /// Current server status
  ServerStatus get currentStatus => _currentStatus;
  
  /// Start monitoring server status with periodic checks
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    _statusTimer?.cancel();
    
    // Initial check
    _checkServerStatus();
    
    // Periodic checks
    _statusTimer = Timer.periodic(interval, (_) => _checkServerStatus());
  }
  
  /// Stop monitoring server status
  void stopMonitoring() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }
  
  /// Manually trigger a server status check
  Future<void> checkStatus() async {
    await _checkServerStatus();
  }
  
  Future<void> _checkServerStatus() async {
    print('ServerStatusService: Checking server status at http://$_host:$_port/');
    try {
      // Try the health check endpoint first
      print('ServerStatusService: Attempting healthCheck...');
      final result = await _client.image.healthCheck()
          .timeout(const Duration(seconds: 5));
      print('ServerStatusService: Health check successful - result: $result');
      _updateStatus(ServerStatus.connected);
    } catch (e) {
      print('ServerStatusService: Health check failed: ${e.runtimeType} - $e');
      // Fallback to listImages if health check fails
      try {
        print('ServerStatusService: Attempting listImages fallback...');
        final images = await _client.image.listImages()
            .timeout(const Duration(seconds: 5));
        print('ServerStatusService: ListImages successful - found ${images.length} images');
        _updateStatus(ServerStatus.connected);
      } catch (e2) {
        print('ServerStatusService: ListImages also failed: ${e2.runtimeType} - $e2');
        _updateStatus(ServerStatus.disconnected);
      }
    }
  }
  
  void _updateStatus(ServerStatus newStatus) {
    print('ServerStatusService: Updating status from $_currentStatus to $newStatus');
    _currentStatus = newStatus;
    _statusController.add(newStatus);
    print('ServerStatusService: Status updated and broadcasted');
  }
  
  void dispose() {
    _statusTimer?.cancel();
    _statusController.close();
  }
}

/// Enum representing different server connection states
enum ServerStatus {
  connected,
  disconnected,
  error,
}

/// Extension to provide display properties for server status
extension ServerStatusDisplay on ServerStatus {
  String get displayText {
    switch (this) {
      case ServerStatus.connected:
        return 'Connected';
      case ServerStatus.disconnected:
        return 'Disconnected';
      case ServerStatus.error:
        return 'Error';
    }
  }
  
  bool get isConnected => this == ServerStatus.connected;
}
