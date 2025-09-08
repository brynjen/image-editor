import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'settings_event.dart';
import 'settings_state.dart';
import '../../domain/model/settings_model.dart';
import '../../data/repository/app_config_service.dart';

/// BLoC for managing application settings
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  Timer? _periodicTimer;
  final http.Client _httpClient = http.Client();

  SettingsBloc() : super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsServerUpdated>(_onServerUpdated);
    on<SettingsSaveRequested>(_onSaveRequested);
    on<SettingsConnectionTestRequested>(_onConnectionTestRequested);
    on<SettingsHealthCheckRequested>(_onHealthCheckRequested);
    on<SettingsPeriodicHealthCheckStarted>(_onPeriodicHealthCheckStarted);
    on<SettingsPeriodicHealthCheckStopped>(_onPeriodicHealthCheckStopped);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final settings = ServerSettings(
        host: prefs.getString('ai_service_host') ?? 'localhost',
        port: prefs.getInt('ai_service_port') ?? 8000,
        scheme: prefs.getString('ai_service_scheme') ?? 'http',
        isConnected: false,
        modelStatus: ModelStatus.initial(),
      );

      emit(SettingsLoaded(settings: settings));
      
      // Automatically check health after loading
      add(const SettingsHealthCheckRequested());
    } catch (e) {
      emit(SettingsError(
        message: 'Failed to load settings: $e',
        settings: ServerSettings.initial(),
      ));
    }
  }

  Future<void> _onServerUpdated(
    SettingsServerUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        host: event.host,
        port: event.port,
        scheme: event.scheme,
        isConnected: false, // Reset connection status when settings change
        modelStatus: ModelStatus.initial(), // Reset model status
      );
      
      emit(currentState.copyWith(settings: updatedSettings));
    }
  }

  Future<void> _onSaveRequested(
    SettingsSaveRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isSaving: true));

      try {
        final settings = currentState.settings;
        
        // Update configuration through AppConfigService
        final appConfigService = AppConfigService();
        await appConfigService.updateConfiguration(
          host: settings.host,
          port: settings.port,
          scheme: settings.scheme,
        );

        emit(SettingsSaved(settings: settings));
      } catch (e) {
        emit(currentState.copyWith(
          isSaving: false,
          error: 'Failed to save settings: $e',
        ));
      }
    }
  }

  Future<void> _onConnectionTestRequested(
    SettingsConnectionTestRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isTesting: true, error: null));

      try {
        final settings = currentState.settings;
        final url = '${settings.url}/health';
        
        final response = await _httpClient
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final healthData = json.decode(response.body) as Map<String, dynamic>;
          final modelStatus = ModelStatus.fromHealthData(healthData);
          
          final updatedSettings = settings.copyWith(
            isConnected: true,
            modelStatus: modelStatus,
            connectionError: null,
            lastChecked: DateTime.now(),
          );
          
          emit(currentState.copyWith(
            settings: updatedSettings,
            isTesting: false,
          ));
        } else {
          final updatedSettings = settings.copyWith(
            isConnected: false,
            connectionError: 'HTTP ${response.statusCode}: ${response.body}',
            lastChecked: DateTime.now(),
          );
          
          emit(currentState.copyWith(
            settings: updatedSettings,
            isTesting: false,
          ));
        }
      } catch (e) {
        final updatedSettings = currentState.settings.copyWith(
          isConnected: false,
          connectionError: e.toString(),
          lastChecked: DateTime.now(),
        );
        
        emit(currentState.copyWith(
          settings: updatedSettings,
          isTesting: false,
        ));
      }
    }
  }

  Future<void> _onHealthCheckRequested(
    SettingsHealthCheckRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      try {
        final settings = currentState.settings;
        
        // Check basic health endpoint
        final healthUrl = '${settings.url}/health';
        final healthResponse = await _httpClient
            .get(Uri.parse(healthUrl))
            .timeout(const Duration(seconds: 5));

        if (healthResponse.statusCode == 200) {
          final healthData = json.decode(healthResponse.body) as Map<String, dynamic>;
          
          // Try to get more detailed model info from Qwen health endpoint
          try {
            final qwenHealthUrl = '${settings.url}/qwen/health'; // Assuming this endpoint exists
            final qwenResponse = await _httpClient
                .get(Uri.parse(qwenHealthUrl))
                .timeout(const Duration(seconds: 5));
                
            if (qwenResponse.statusCode == 200) {
              final qwenData = json.decode(qwenResponse.body) as Map<String, dynamic>;
              // Merge health data with qwen data
              healthData.addAll(qwenData);
            }
          } catch (e) {
            // Qwen health endpoint might not exist, continue with basic health data
          }
          
          final modelStatus = ModelStatus.fromHealthData(healthData);
          
          final updatedSettings = settings.copyWith(
            isConnected: true,
            modelStatus: modelStatus,
            connectionError: null,
            lastChecked: DateTime.now(),
          );
          
          emit(currentState.copyWith(settings: updatedSettings));
        } else {
          final updatedSettings = settings.copyWith(
            isConnected: false,
            connectionError: 'Health check failed: HTTP ${healthResponse.statusCode}',
            lastChecked: DateTime.now(),
          );
          
          emit(currentState.copyWith(settings: updatedSettings));
        }
      } catch (e) {
        final updatedSettings = currentState.settings.copyWith(
          isConnected: false,
          connectionError: 'Health check failed: $e',
          lastChecked: DateTime.now(),
        );
        
        emit(currentState.copyWith(settings: updatedSettings));
      }
    }
  }

  Future<void> _onPeriodicHealthCheckStarted(
    SettingsPeriodicHealthCheckStarted event,
    Emitter<SettingsState> emit,
  ) async {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const SettingsHealthCheckRequested()),
    );
  }

  Future<void> _onPeriodicHealthCheckStopped(
    SettingsPeriodicHealthCheckStopped event,
    Emitter<SettingsState> emit,
  ) async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  @override
  Future<void> close() {
    _periodicTimer?.cancel();
    _httpClient.close();
    return super.close();
  }
}
