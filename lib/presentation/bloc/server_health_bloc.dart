import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'server_health_event.dart';
import 'server_health_state.dart';

/// BLoC for handling server health checks
class ServerHealthBloc extends Bloc<ServerHealthEvent, ServerHealthState> {
  final http.Client _httpClient;

  ServerHealthBloc({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client(),
        super(const ServerHealthInitial()) {
    on<ServerHealthCheckRequested>(_onHealthCheckRequested);
    on<ServerHealthCheckReset>(_onHealthCheckReset);
  }

  Future<void> _onHealthCheckRequested(
    ServerHealthCheckRequested event,
    Emitter<ServerHealthState> emit,
  ) async {
    final serverUrl = '${event.scheme}://${event.host}:${event.port}';
    final healthUrl = '$serverUrl/health';

    emit(ServerHealthChecking(serverUrl));

    try {
      final stopwatch = Stopwatch()..start();

      final response = await _httpClient
          .get(
            Uri.parse(healthUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();
      final responseTime = stopwatch.elapsed;

      if (response.statusCode == 200) {
        try {
          final healthData = json.decode(response.body) as Map<String, dynamic>;
          emit(ServerHealthSuccess(
            serverUrl: serverUrl,
            healthData: healthData,
            responseTime: responseTime,
          ));
        } catch (e) {
          // If JSON parsing fails, treat as success but with limited data
          emit(ServerHealthSuccess(
            serverUrl: serverUrl,
            healthData: {
              'status': 'healthy',
              'raw_response': response.body,
            },
            responseTime: responseTime,
          ));
        }
      } else {
        emit(ServerHealthFailure(
          serverUrl: serverUrl,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          responseTime: responseTime,
        ));
      }
    } on TimeoutException {
      emit(ServerHealthFailure(
        serverUrl: serverUrl,
        error: 'Connection timeout (10 seconds)',
      ));
    } on http.ClientException catch (e) {
      emit(ServerHealthFailure(
        serverUrl: serverUrl,
        error: 'Network error: ${e.message}',
      ));
    } catch (e) {
      emit(ServerHealthFailure(
        serverUrl: serverUrl,
        error: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  void _onHealthCheckReset(
    ServerHealthCheckReset event,
    Emitter<ServerHealthState> emit,
  ) {
    emit(const ServerHealthInitial());
  }

  @override
  Future<void> close() {
    _httpClient.close();
    return super.close();
  }
}
