import '../../data/repository/server_status_service.dart';

/// State class for server status
class ServerStatusState {
  final ServerStatus status;
  final bool isMonitoring;
  final DateTime? lastChecked;
  
  const ServerStatusState({
    required this.status,
    required this.isMonitoring,
    this.lastChecked,
  });
  
  /// Initial state
  factory ServerStatusState.initial() {
    return const ServerStatusState(
      status: ServerStatus.disconnected,
      isMonitoring: false,
    );
  }
  
  /// Copy with new values
  ServerStatusState copyWith({
    ServerStatus? status,
    bool? isMonitoring,
    DateTime? lastChecked,
  }) {
    return ServerStatusState(
      status: status ?? this.status,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}
