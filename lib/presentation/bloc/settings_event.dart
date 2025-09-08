import 'package:equatable/equatable.dart';

/// Events for the settings BLoC
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load current settings from storage
class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

/// Update server connection settings
class SettingsServerUpdated extends SettingsEvent {
  final String host;
  final int port;
  final String scheme;

  const SettingsServerUpdated({
    required this.host,
    required this.port,
    required this.scheme,
  });

  @override
  List<Object?> get props => [host, port, scheme];
}

/// Save current settings to storage
class SettingsSaveRequested extends SettingsEvent {
  const SettingsSaveRequested();
}

/// Test server connection
class SettingsConnectionTestRequested extends SettingsEvent {
  const SettingsConnectionTestRequested();
}

/// Check server health and model status
class SettingsHealthCheckRequested extends SettingsEvent {
  const SettingsHealthCheckRequested();
}

/// Start periodic health checks
class SettingsPeriodicHealthCheckStarted extends SettingsEvent {
  const SettingsPeriodicHealthCheckStarted();
}

/// Stop periodic health checks
class SettingsPeriodicHealthCheckStopped extends SettingsEvent {
  const SettingsPeriodicHealthCheckStopped();
}

