import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/server_status_service.dart';
import 'server_status_event.dart';
import 'server_status_state.dart';

/// BLoC for managing server status
class ServerStatusBloc extends Bloc<ServerStatusEvent, ServerStatusState> {
  final ServerStatusService _serverStatusService;
  StreamSubscription<ServerStatus>? _statusSubscription;
  
  ServerStatusBloc(this._serverStatusService) : super(ServerStatusState.initial()) {
    on<ServerStatusMonitoringStarted>(_onMonitoringStarted);
    on<ServerStatusMonitoringStopped>(_onMonitoringStopped);
    on<ServerStatusChanged>(_onStatusChanged);
    on<ServerStatusCheckRequested>(_onCheckRequested);
  }
  
  Future<void> _onMonitoringStarted(
    ServerStatusMonitoringStarted event,
    Emitter<ServerStatusState> emit,
  ) async {
    if (state.isMonitoring) return;
    
    emit(state.copyWith(isMonitoring: true));
    
    // Subscribe to status changes
    _statusSubscription = _serverStatusService.statusStream.listen(
      (status) => add(ServerStatusChanged(status)),
    );
    
    // Start monitoring
    _serverStatusService.startMonitoring();
  }
  
  Future<void> _onMonitoringStopped(
    ServerStatusMonitoringStopped event,
    Emitter<ServerStatusState> emit,
  ) async {
    if (!state.isMonitoring) return;
    
    emit(state.copyWith(isMonitoring: false));
    
    // Cancel subscription
    await _statusSubscription?.cancel();
    _statusSubscription = null;
    
    // Stop monitoring
    _serverStatusService.stopMonitoring();
  }
  
  void _onStatusChanged(
    ServerStatusChanged event,
    Emitter<ServerStatusState> emit,
  ) {
    emit(state.copyWith(
      status: event.status,
      lastChecked: DateTime.now(),
    ));
  }
  
  Future<void> _onCheckRequested(
    ServerStatusCheckRequested event,
    Emitter<ServerStatusState> emit,
  ) async {
    print('ServerStatusBloc: Manual check requested');
    await _serverStatusService.checkStatus();
  }
  
  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _serverStatusService.stopMonitoring();
    _serverStatusService.dispose();
    return super.close();
  }
}
