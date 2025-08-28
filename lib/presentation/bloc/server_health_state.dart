import 'package:equatable/equatable.dart';

/// States for server health check BLoC
abstract class ServerHealthState extends Equatable {
  const ServerHealthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no health check performed
class ServerHealthInitial extends ServerHealthState {
  const ServerHealthInitial();
}

/// Health check is in progress
class ServerHealthChecking extends ServerHealthState {
  final String serverUrl;

  const ServerHealthChecking(this.serverUrl);

  @override
  List<Object?> get props => [serverUrl];
}

/// Health check completed successfully
class ServerHealthSuccess extends ServerHealthState {
  final String serverUrl;
  final Map<String, dynamic> healthData;
  final Duration responseTime;

  const ServerHealthSuccess({
    required this.serverUrl,
    required this.healthData,
    required this.responseTime,
  });

  @override
  List<Object?> get props => [serverUrl, healthData, responseTime];

  bool get isModelLoaded => healthData['model_loaded'] == true;
  String get status => healthData['status']?.toString() ?? 'unknown';
  Map<String, dynamic>? get modelInfo => healthData['model_info'] as Map<String, dynamic>?;
}

/// Health check failed
class ServerHealthFailure extends ServerHealthState {
  final String serverUrl;
  final String error;
  final Duration? responseTime;

  const ServerHealthFailure({
    required this.serverUrl,
    required this.error,
    this.responseTime,
  });

  @override
  List<Object?> get props => [serverUrl, error, responseTime];
}
