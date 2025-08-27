import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/server_status_service.dart';
import '../bloc/server_status_bloc.dart';
import '../bloc/server_status_event.dart';
import '../bloc/server_status_state.dart';

/// Widget that displays server connection status with a colored indicator
class ServerStatusWidget extends StatefulWidget {
  const ServerStatusWidget({super.key});

  @override
  State<ServerStatusWidget> createState() => _ServerStatusWidgetState();
}

class _ServerStatusWidgetState extends State<ServerStatusWidget> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerStatusBloc, ServerStatusState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(state.status),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(state.status),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status indicator dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getIndicatorColor(state.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              
              // Status text
              Text(
                'Server: ${state.status.displayText}',
                style: TextStyle(
                  color: _getTextColor(state.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Refresh button
              const SizedBox(width: 4),
              InkWell(
                onTap: () async {
                  print('ServerStatusWidget: Refresh button tapped');
                  setState(() => _isRefreshing = true);
                  context.read<ServerStatusBloc>().add(
                    const ServerStatusCheckRequested(),
                  );
                  // Show refresh animation for at least 1 second
                  await Future.delayed(const Duration(milliseconds: 1000));
                  if (mounted) {
                    setState(() => _isRefreshing = false);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _isRefreshing
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: _getTextColor(state.status),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          size: 14,
                          color: _getTextColor(state.status),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getIndicatorColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.connected:
        return Colors.green;
      case ServerStatus.disconnected:
        return Colors.red;
      case ServerStatus.error:
        return Colors.orange;
    }
  }

  Color _getBackgroundColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.connected:
        return Colors.green.withOpacity(0.1);
      case ServerStatus.disconnected:
        return Colors.red.withOpacity(0.1);
      case ServerStatus.error:
        return Colors.orange.withOpacity(0.1);
    }
  }

  Color _getBorderColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.connected:
        return Colors.green.withOpacity(0.3);
      case ServerStatus.disconnected:
        return Colors.red.withOpacity(0.3);
      case ServerStatus.error:
        return Colors.orange.withOpacity(0.3);
    }
  }

  Color _getTextColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.connected:
        return Colors.green.shade700;
      case ServerStatus.disconnected:
        return Colors.red.shade700;
      case ServerStatus.error:
        return Colors.orange.shade700;
    }
  }
}
