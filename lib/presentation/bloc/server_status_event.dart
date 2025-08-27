import '../../data/repository/server_status_service.dart';

/// Base class for server status events
abstract class ServerStatusEvent {
  const ServerStatusEvent();
}

/// Event to start monitoring server status
class ServerStatusMonitoringStarted extends ServerStatusEvent {
  const ServerStatusMonitoringStarted();
}

/// Event to stop monitoring server status
class ServerStatusMonitoringStopped extends ServerStatusEvent {
  const ServerStatusMonitoringStopped();
}

/// Event when server status changes
class ServerStatusChanged extends ServerStatusEvent {
  final ServerStatus status;
  
  const ServerStatusChanged(this.status);
}

/// Event to manually check server status
class ServerStatusCheckRequested extends ServerStatusEvent {
  const ServerStatusCheckRequested();
}
