import 'package:equatable/equatable.dart';

/// Model status information
class ModelStatus extends Equatable {
  final bool isLoaded;
  final bool isDownloading;
  final double downloadProgress; // 0.0 to 1.0
  final String? modelName;
  final String? error;
  final DateTime? lastChecked;

  const ModelStatus({
    required this.isLoaded,
    required this.isDownloading,
    this.downloadProgress = 0.0,
    this.modelName,
    this.error,
    this.lastChecked,
  });

  factory ModelStatus.initial() {
    return const ModelStatus(
      isLoaded: false,
      isDownloading: false,
      downloadProgress: 0.0,
    );
  }

  factory ModelStatus.fromHealthData(Map<String, dynamic> healthData) {
    final modelInfo = healthData['model_info'] as Map<String, dynamic>?;
    
    return ModelStatus(
      isLoaded: healthData['model_loaded'] == true,
      isDownloading: healthData['model_downloading'] == true,
      downloadProgress: (healthData['download_progress'] as num?)?.toDouble() ?? 0.0,
      modelName: modelInfo?['model_name']?.toString(),
      lastChecked: DateTime.now(),
    );
  }

  ModelStatus copyWith({
    bool? isLoaded,
    bool? isDownloading,
    double? downloadProgress,
    String? modelName,
    String? error,
    DateTime? lastChecked,
  }) {
    return ModelStatus(
      isLoaded: isLoaded ?? this.isLoaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      modelName: modelName ?? this.modelName,
      error: error ?? this.error,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  List<Object?> get props => [
        isLoaded,
        isDownloading,
        downloadProgress,
        modelName,
        error,
        lastChecked,
      ];
}

/// Server connection settings
class ServerSettings extends Equatable {
  final String host;
  final int port;
  final String scheme;
  final bool isConnected;
  final ModelStatus modelStatus;
  final String? connectionError;
  final DateTime? lastChecked;

  const ServerSettings({
    required this.host,
    required this.port,
    required this.scheme,
    required this.isConnected,
    required this.modelStatus,
    this.connectionError,
    this.lastChecked,
  });

  factory ServerSettings.initial() {
    return const ServerSettings(
      host: '192.168.0.74',
      port: 8000,
      scheme: 'http',
      isConnected: false,
      modelStatus: ModelStatus(isLoaded: false, isDownloading: false),
    );
  }

  String get url => '$scheme://$host:$port';

  ServerSettings copyWith({
    String? host,
    int? port,
    String? scheme,
    bool? isConnected,
    ModelStatus? modelStatus,
    String? connectionError,
    DateTime? lastChecked,
  }) {
    return ServerSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      scheme: scheme ?? this.scheme,
      isConnected: isConnected ?? this.isConnected,
      modelStatus: modelStatus ?? this.modelStatus,
      connectionError: connectionError ?? this.connectionError,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  List<Object?> get props => [
        host,
        port,
        scheme,
        isConnected,
        modelStatus,
        connectionError,
        lastChecked,
      ];
}

