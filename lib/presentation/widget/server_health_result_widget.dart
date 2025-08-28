import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bloc/server_health_state.dart';

/// Widget to display server health check results
class ServerHealthResultWidget extends StatelessWidget {
  final ServerHealthState healthState;

  const ServerHealthResultWidget({
    super.key,
    required this.healthState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(context)),
        color: _getBackgroundColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(),
                color: _getIconColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTitle(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(context),
                  ),
                ),
              ),
              if (healthState is ServerHealthSuccess || healthState is ServerHealthFailure)
                Text(
                  _getResponseTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getSubtitle(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          if (healthState is ServerHealthSuccess) ..._buildSuccessDetails(context),
          if (healthState is ServerHealthFailure) ..._buildFailureDetails(context),
        ],
      ),
    );
  }

  List<Widget> _buildSuccessDetails(BuildContext context) {
    final state = healthState as ServerHealthSuccess;
    
    return [
      const SizedBox(height: 12),
      if (state.healthData.isNotEmpty) ...[
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Server Details:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ..._buildHealthDataItems(state.healthData),
      ],
    ];
  }

  List<Widget> _buildHealthDataItems(Map<String, dynamic> healthData) {
    final items = <Widget>[];
    
    // Status
    if (healthData.containsKey('status')) {
      items.add(_buildDetailRow('Status', healthData['status'].toString()));
    }
    
    // Model loaded status
    if (healthData.containsKey('model_loaded')) {
      items.add(_buildDetailRow(
        'Model Loaded', 
        healthData['model_loaded'] == true ? 'Yes' : 'No',
        isGood: healthData['model_loaded'] == true,
      ));
    }
    
    // Model info
    if (healthData.containsKey('model_info') && healthData['model_info'] is Map) {
      final modelInfo = healthData['model_info'] as Map<String, dynamic>;
      
      if (modelInfo.containsKey('model_name')) {
        items.add(_buildDetailRow('Model', modelInfo['model_name'].toString()));
      }
      
      if (modelInfo.containsKey('device')) {
        items.add(_buildDetailRow('Device', modelInfo['device'].toString()));
      }
      
      if (modelInfo.containsKey('model_type')) {
        items.add(_buildDetailRow('Type', modelInfo['model_type'].toString()));
      }
    }
    
    return items;
  }

  Widget _buildDetailRow(String label, String value, {bool? isGood}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (isGood != null) ...[
                  Icon(
                    isGood ? Icons.check_circle : Icons.error,
                    size: 14,
                    color: isGood ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: isGood == true ? Colors.green[700] : 
                             isGood == false ? Colors.red[700] : null,
                      fontFamily: value.contains('/') || value.contains(':') ? 'monospace' : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFailureDetails(BuildContext context) {
    final state = healthState as ServerHealthFailure;
    
    return [
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    state.error,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: state.error));
              },
              icon: const Icon(Icons.copy, size: 16),
              tooltip: 'Copy error',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      ),
    ];
  }

  IconData _getIcon() {
    return switch (healthState) {
      ServerHealthChecking _ => Icons.hourglass_empty,
      ServerHealthSuccess _ => Icons.check_circle,
      ServerHealthFailure _ => Icons.error,
      _ => Icons.help_outline,
    };
  }

  Color _getIconColor(BuildContext context) {
    return switch (healthState) {
      ServerHealthChecking _ => Colors.orange,
      ServerHealthSuccess _ => Colors.green,
      ServerHealthFailure _ => Colors.red,
      _ => Colors.grey,
    };
  }

  Color _getBorderColor(BuildContext context) {
    return switch (healthState) {
      ServerHealthChecking _ => Colors.orange[300]!,
      ServerHealthSuccess _ => Colors.green[300]!,
      ServerHealthFailure _ => Colors.red[300]!,
      _ => Colors.grey[300]!,
    };
  }

  Color _getBackgroundColor(BuildContext context) {
    return switch (healthState) {
      ServerHealthChecking _ => Colors.orange[50]!,
      ServerHealthSuccess _ => Colors.green[50]!,
      ServerHealthFailure _ => Colors.red[50]!,
      _ => Colors.grey[50]!,
    };
  }

  Color _getTextColor(BuildContext context) {
    return switch (healthState) {
      ServerHealthChecking _ => Colors.orange[800]!,
      ServerHealthSuccess _ => Colors.green[800]!,
      ServerHealthFailure _ => Colors.red[800]!,
      _ => Colors.grey[800]!,
    };
  }

  String _getTitle() {
    return switch (healthState) {
      ServerHealthChecking _ => 'Testing Connection...',
      ServerHealthSuccess _ => 'Connection Successful!',
      ServerHealthFailure _ => 'Connection Failed',
      _ => 'Ready to Test',
    };
  }

  String _getSubtitle() {
    return switch (healthState) {
      ServerHealthChecking(:final serverUrl) => 'Connecting to $serverUrl...',
      ServerHealthSuccess(:final serverUrl) => 'Successfully connected to $serverUrl',
      ServerHealthFailure(:final serverUrl) => 'Failed to connect to $serverUrl',
      _ => 'Click "Test Connection" to verify server availability',
    };
  }

  String _getResponseTime() {
    if (healthState is ServerHealthSuccess) {
      final state = healthState as ServerHealthSuccess;
      return '${state.responseTime.inMilliseconds}ms';
    } else if (healthState is ServerHealthFailure) {
      final state = healthState as ServerHealthFailure;
      if (state.responseTime != null) {
        return '${state.responseTime!.inMilliseconds}ms';
      }
    }
    return '';
  }
}
