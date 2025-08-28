import 'package:equatable/equatable.dart';

/// Events for server health check BLoC
abstract class ServerHealthEvent extends Equatable {
  const ServerHealthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a health check for a specific server configuration
class ServerHealthCheckRequested extends ServerHealthEvent {
  final String host;
  final int port;
  final String scheme;

  const ServerHealthCheckRequested({
    required this.host,
    required this.port,
    required this.scheme,
  });

  @override
  List<Object?> get props => [host, port, scheme];
}

/// Event to reset the health check state
class ServerHealthCheckReset extends ServerHealthEvent {
  const ServerHealthCheckReset();
}
