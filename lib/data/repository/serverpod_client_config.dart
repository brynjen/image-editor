import 'package:image_editor_server_client/image_editor_server_client.dart';

/// Configuration and factory for Serverpod client
class ServerpodClientConfig {
  static const String _defaultHost = '127.0.0.1';
  static const int _defaultPort = 8080;
  static const bool _useSecureConnection = false;

  static Client createClient({
    String host = _defaultHost,
    int port = _defaultPort,
    bool secure = _useSecureConnection,
  }) {
    return Client(
      'http${secure ? 's' : ''}://$host:$port/',
    );
  }
}
