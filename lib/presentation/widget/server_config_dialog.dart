import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/server_health_bloc.dart';
import '../bloc/server_health_event.dart';
import '../bloc/server_health_state.dart';
import 'server_health_result_widget.dart';

/// Dialog for configuring remote AI server settings
class ServerConfigDialog extends StatelessWidget {
  const ServerConfigDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServerHealthBloc(),
      child: const _ServerConfigDialogView(),
    );
  }
}

/// Internal dialog view with BLoC access
class _ServerConfigDialogView extends StatefulWidget {
  const _ServerConfigDialogView();

  @override
  State<_ServerConfigDialogView> createState() => _ServerConfigDialogViewState();
}

class _ServerConfigDialogViewState extends State<_ServerConfigDialogView> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  String _selectedScheme = 'http';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _hostController.text = prefs.getString('ai_service_host') ?? 'localhost';
        _portController.text = prefs.getInt('ai_service_port')?.toString() ?? '8000';
        _selectedScheme = prefs.getString('ai_service_scheme') ?? 'http';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hostController.text = 'localhost';
        _portController.text = '8000';
        _selectedScheme = 'http';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('ai_service_host', _hostController.text.trim());
      await prefs.setInt('ai_service_port', int.parse(_portController.text.trim()));
      await prefs.setString('ai_service_scheme', _selectedScheme);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate settings were saved
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server configuration saved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _testConnection() {
    if (!_formKey.currentState!.validate()) return;

    final host = _hostController.text.trim();
    final port = int.parse(_portController.text.trim());
    final scheme = _selectedScheme;

    // Reset previous health check state
    context.read<ServerHealthBloc>().add(const ServerHealthCheckReset());

    // Start health check
    context.read<ServerHealthBloc>().add(
      ServerHealthCheckRequested(
        host: host,
        port: port,
        scheme: scheme,
      ),
    );
  }

  String? _validateHost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host is required';
    }
    
    final host = value.trim();
    
    // Basic validation for IP address or hostname
    if (host == 'localhost') return null;
    
    // Simple IP address pattern (not perfect but good enough)
    final ipPattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (ipPattern.hasMatch(host)) {
      // Validate IP octets
      final parts = host.split('.');
      for (final part in parts) {
        final octet = int.tryParse(part);
        if (octet == null || octet < 0 || octet > 255) {
          return 'Invalid IP address';
        }
      }
      return null;
    }
    
    // Simple hostname validation
    final hostnamePattern = RegExp(r'^[a-zA-Z0-9.-]+$');
    if (!hostnamePattern.hasMatch(host)) {
      return 'Invalid hostname format';
    }
    
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required';
    }
    
    final port = int.tryParse(value.trim());
    if (port == null || port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings_ethernet),
          SizedBox(width: 8),
          Text('AI Server Configuration'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              width: 300,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure the remote AI server for image processing:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    
                    // Scheme selection
                    const Text(
                      'Protocol',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedScheme,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'http', child: Text('HTTP')),
                        DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedScheme = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Host input
                    const Text(
                      'Host / IP Address',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., 192.168.1.100 or localhost',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        prefixIcon: Icon(Icons.computer),
                      ),
                      validator: _validateHost,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // Port input
                    const Text(
                      'Port',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        hintText: '8000',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        prefixIcon: Icon(Icons.router),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePort,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    
                    // Current URL preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.link, color: Colors.blue[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI Service URL: $_selectedScheme://${_hostController.text.isEmpty ? 'host' : _hostController.text}:${_portController.text.isEmpty ? 'port' : _portController.text}',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Health check results
                    BlocBuilder<ServerHealthBloc, ServerHealthState>(
                      builder: (context, healthState) {
                        if (healthState is ServerHealthInitial) {
                          return const SizedBox.shrink();
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connection Test Results:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ServerHealthResultWidget(healthState: healthState),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        BlocBuilder<ServerHealthBloc, ServerHealthState>(
          builder: (context, healthState) {
            final isTesting = healthState is ServerHealthChecking;
            
            return TextButton(
              onPressed: _isLoading || _isSaving || isTesting ? null : _testConnection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTesting) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 4),
                    const Text('Testing...'),
                  ] else ...[
                    const Icon(Icons.network_check, size: 16),
                    const SizedBox(width: 4),
                    const Text('Test Connection'),
                  ],
                ],
              ),
            );
          },
        ),
        TextButton(
          onPressed: _isLoading || _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isSaving ? null : _saveSettings,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
